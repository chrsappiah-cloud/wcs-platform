//
//  VideoPlayerView.swift
//  WCS-Platform
//

import AVKit
import SwiftUI

struct VideoPlayerView: View {
    @StateObject private var viewModel: VideoPlayerViewModel
    let title: String

    init(url: URL, courseId: UUID, moduleId: UUID, lessonId: UUID, title: String) {
        self.title = title
        _viewModel = StateObject(
            wrappedValue: VideoPlayerViewModel(
                url: url,
                courseId: courseId,
                moduleId: moduleId,
                lessonId: lessonId
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                VideoPlayer(player: viewModel.player)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                            .strokeBorder(DesignTokens.subtleBorder, lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button {
                            viewModel.togglePlayPause()
                        } label: {
                            Label(
                                viewModel.isPlaying ? "Pause" : "Play",
                                systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill"
                            )
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .frame(width: 52, height: 52)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.brand)

                        Spacer(minLength: 0)

                        Button {
                            Task { await viewModel.markLessonComplete() }
                        } label: {
                            Label("Mark complete", systemImage: "checkmark.circle.fill")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.brandAccent)
                    }

                    if viewModel.totalSeconds > 0 {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Slider(
                                value: Binding(
                                    get: { viewModel.progressSeconds / max(viewModel.totalSeconds, 0.0001) },
                                    set: { viewModel.seek(toFraction: $0) }
                                )
                            )
                            .tint(DesignTokens.brandAccent)
                            Text(timelineText)
                                .font(.caption.monospacedDigit().weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let error = viewModel.lastError {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(DesignTokens.Spacing.md)
                .wcsElevatedSurface()
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .wcsGroupedScreen()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .onDisappear {
            viewModel.cleanup()
        }
    }

    private var timelineText: String {
        let cur = Int(viewModel.progressSeconds.rounded(.down))
        let tot = Int(viewModel.totalSeconds.rounded(.down))
        return "\(format(cur)) / \(format(tot))"
    }

    private func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    NavigationStack {
        VideoPlayerView(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
            courseId: UUID(),
            moduleId: UUID(),
            lessonId: UUID(),
            title: "Preview"
        )
    }
}
