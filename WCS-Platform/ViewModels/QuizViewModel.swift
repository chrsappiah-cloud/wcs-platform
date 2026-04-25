//
//  QuizViewModel.swift
//  WCS-Platform
//

import Combine
import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var quiz: Quiz
    @Published var currentIndex: Int = 0
    @Published var selections: [UUID: Int] = [:]
    @Published var isSubmitting = false
    @Published var result: QuizSubmissionResult?
    @Published var lastError: WCSAPIError?

    var currentQuestion: Question? {
        guard quiz.questions.indices.contains(currentIndex) else { return nil }
        return quiz.questions[currentIndex]
    }

    init(quiz: Quiz) {
        self.quiz = quiz
    }

    func selectOption(index: Int) {
        guard let q = currentQuestion else { return }
        selections[q.id] = index
    }

    func next() {
        guard currentIndex + 1 < quiz.questions.count else { return }
        currentIndex += 1
    }

    func previous() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func submit() async {
        isSubmitting = true
        lastError = nil
        defer { isSubmitting = false }
        do {
            result = try await NetworkClient.shared.submitQuiz(quiz.id, answers: selections)
        } catch let api as WCSAPIError {
            lastError = api
        } catch {
            lastError = WCSAPIError(underlying: error, statusCode: nil, body: nil)
        }
    }

    func resetAttempt() {
        result = nil
        currentIndex = 0
        selections = [:]
        lastError = nil
    }
}
