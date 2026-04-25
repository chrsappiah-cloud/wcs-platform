//
//  VideoPlayerViewModel.swift
//  WCS-Platform
//

import AVFoundation
import Combine
import Foundation

final class VideoPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var isBuffering = false
    @Published var progressSeconds: Double = 0
    @Published var totalSeconds: Double = 0
    @Published var lastError: WCSAPIError?

    let player: AVPlayer

    private var timeObserverToken: Any?
    private var statusCancellable: AnyCancellable?

    private let courseId: UUID
    private let moduleId: UUID
    private let lessonId: UUID

    init(url: URL, courseId: UUID, moduleId: UUID, lessonId: UUID) {
        self.courseId = courseId
        self.moduleId = moduleId
        self.lessonId = lessonId
        self.player = AVPlayer(url: url)

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.tick(time: time)
        }

        statusCancellable = player.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatus()
            }
    }

    deinit {
        cleanup()
    }

    func cleanup() {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        statusCancellable?.cancel()
        statusCancellable = nil
        player.pause()
    }

    private func tick(time: CMTime) {
        let current = CMTimeGetSeconds(time)
        progressSeconds = current.isFinite ? current : 0

        if let duration = player.currentItem?.duration, duration.isValid, !duration.isIndefinite {
            let total = CMTimeGetSeconds(duration)
            totalSeconds = total.isFinite && total > 0 ? total : 0
        }
    }

    private func updateStatus() {
        switch player.status {
        case .readyToPlay:
            isPlaying = player.rate > 0
            isBuffering = !(player.currentItem?.isPlaybackLikelyToKeepUp ?? true)
        case .failed:
            isPlaying = false
            isBuffering = false
            lastError = WCSAPIError(
                underlying: player.error ?? URLError(.unknown),
                statusCode: nil,
                body: nil
            )
        default:
            isPlaying = false
            isBuffering = true
        }
    }

    func togglePlayPause() {
        if player.rate > 0 {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func seek(toFraction fraction: Double) {
        let clamped = min(1, max(0, fraction))
        let seconds = clamped * totalSeconds
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: time)
    }

    func markLessonComplete() async {
        do {
            _ = try await NetworkClient.shared.updateLessonProgress(
                courseId: courseId,
                moduleId: moduleId,
                lessonId: lessonId,
                complete: true
            )
        } catch let api as WCSAPIError {
            lastError = api
        } catch {
            lastError = WCSAPIError(underlying: error, statusCode: nil, body: nil)
        }
    }
}
