//
//  CourseDetailViewModel.swift
//  WCS-Platform
//

import Combine
import Foundation

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published var course: Course?
    /// Avoids a one-frame “empty” detail state before `loadCourse()` runs.
    @Published var isLoading = true
    @Published var lastError: WCSAPIError?
    @Published var isEnrolled = false

    private let courseId: UUID

    init(courseId: UUID) {
        self.courseId = courseId
    }

    func loadCourse() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            let loaded = try await NetworkClient.shared.fetchCourse(courseId)
            course = loaded
            isEnrolled = loaded.isEnrolled
        } catch let api as WCSAPIError {
            lastError = api
        } catch {
            lastError = WCSAPIError(underlying: error, statusCode: nil, body: nil)
        }
    }

    func enroll() async {
        isLoading = true
        lastError = nil
        defer { isLoading = false }
        do {
            _ = try await NetworkClient.shared.enrollInCourse(courseId)
            await loadCourse()
        } catch let api as WCSAPIError {
            lastError = api
        } catch {
            lastError = WCSAPIError(underlying: error, statusCode: nil, body: nil)
        }
    }
}
