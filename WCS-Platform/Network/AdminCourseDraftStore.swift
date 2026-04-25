//
//  AdminCourseDraftStore.swift
//  WCS-Platform
//

import Foundation

actor AdminCourseDraftStore {
    static let shared = AdminCourseDraftStore(generator: MockAICourseGenerator())

    private var drafts: [AdminCourseDraft] = []
    private let generator: AICourseGenerating
    private let blockedAICourseTitleTerms = [
        "beginner",
        "beginners",
        "novice"
    ]
    private let blockedPublishTerms = [
        "search question",
        "search query",
        "what is",
        "how to",
        "why does",
        "can i",
        "?"
    ]

    init(generator: AICourseGenerating) {
        self.generator = generator
    }

    private func notifyChange() {
        Task { @MainActor in
            NotificationCenter.default.post(name: .wcsAdminDraftsDidChange, object: nil)
        }
    }

    func allDrafts() -> [AdminCourseDraft] {
        purgeBlockedDrafts()
        return drafts.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    func generate(prompt: String, createdBy: String, accessTier: AdminCourseAccessTier) async throws -> AdminCourseDraft {
        let draft = try await generator.generateDraft(prompt: prompt, createdBy: createdBy, accessTier: accessTier)
        if isBlockedAICourseTitle(draft.title) {
            purgeBlockedDrafts()
            notifyChange()
            throw NSError(domain: "WCSAdminAI", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "This beginner/novice AI course is blocked and has been removed."
            ])
        }
        drafts.insert(draft, at: 0)
        notifyChange()
        return draft
    }

    func markPublished(_ id: UUID) async throws {
        guard let idx = drafts.firstIndex(where: { $0.id == id }) else { return }
        guard isPublishableGeneratedOutput(drafts[idx]) else {
            throw NSError(domain: "WCSAdminAI", code: 1002, userInfo: [
                NSLocalizedDescriptionKey: "Publish blocked: only structured AI-generated course outputs can be published. Remove search/question-style inputs and regenerate."
            ])
        }
        drafts[idx].status = .published
        drafts[idx].updatedAt = Date()
        await MockLearningStore.shared.publishDraftToCatalog(drafts[idx])
        notifyChange()
    }

    func clearAll() {
        drafts.removeAll()
        notifyChange()
    }

    func deleteBlockedDraftsAndCourses() async {
        purgeBlockedDrafts()
        await MockLearningStore.shared.deleteBlockedAICourses()
        notifyChange()
    }

    private func isBlockedAICourseTitle(_ title: String) -> Bool {
        let lower = title.lowercased()
        return blockedAICourseTitleTerms.contains(where: { lower.contains($0) })
    }

    private func purgeBlockedDrafts() {
        drafts.removeAll { isBlockedAICourseTitle($0.title) }
    }

    private func isPublishableGeneratedOutput(_ draft: AdminCourseDraft) -> Bool {
        guard !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !draft.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !draft.modules.isEmpty else { return false }
        guard draft.modules.allSatisfy({ !$0.lessons.isEmpty }) else { return false }

        let normalized = "\(draft.title) \(draft.summary)".lowercased()
        if blockedPublishTerms.contains(where: { normalized.contains($0) }) {
            return false
        }

        // Must contain evidence of generated course structure, not raw retrieval prompts.
        let hasCourseSignals = !draft.outcomes.isEmpty &&
            draft.reasoningReport != nil &&
            draft.researchTrace != nil &&
            !draft.reportFindings.isEmpty
        return hasCourseSignals
    }
}
