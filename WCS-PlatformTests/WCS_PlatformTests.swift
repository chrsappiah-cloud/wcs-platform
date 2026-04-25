//
//  WCS_PlatformTests.swift
//  WCS-PlatformTests
//
//  Created by Christopher Appiah-Thompson  on 25/4/2026.
//

import Testing
import Foundation
@testable import WCS_Platform

struct WCS_PlatformTests {

    @Test func publishedAIDraftHasStructuredBriefAndReport() async throws {
        await MockLearningStore.shared.deleteBlockedAICourses()
        await MockLearningStore.shared.publishDraftToCatalog(makeDraftForTests(
            title: "AI Business Operator",
            summary: "AI-generated draft for administrators only. Includes module video lessons plus course materials from open-source references for internal review before publication.",
            outcomePrefix: "Build real AI operating workflows",
            includeFindings: true
        ))

        let courses = await MockLearningStore.shared.snapshotCourses(forPremiumUser: true)
        guard let published = courses.first(where: { $0.title == "AI Business Operator" }) else {
            #expect(Bool(false), "Published draft course should exist in catalog.")
            return
        }

        #expect(published.description.contains("Course design goals:"))
        #expect(published.description.contains("Module overview:"))
        #expect(published.description.contains("Learning outcomes:"))
        #expect(published.courseReport != nil)
        #expect((published.courseReport?.learningOutcomes.count ?? 0) > 0)
    }

    @Test func publishGuardBlocksQuestionStyleOutput() async throws {
        let store = AdminCourseDraftStore(generator: StubQuestionGenerator())
        let prompt = """
        Build a WCS AI Course Generation blueprint using a retrieval-plan-generate workflow.
        Product name: What is AI?
        Ideal learner: general users
        Transformation promise: understand AI
        Offer stack: modules and quizzes
        Launch angle: awareness
        Additional curriculum and brand notes: none
        """

        let generated = try await store.generate(prompt: prompt, createdBy: "admin@wcs", accessTier: .freePublic)
        #expect(generated.title.lowercased().contains("what is"))

        await #expect(throws: Error.self) {
            try await store.markPublished(generated.id)
        }
    }

    @Test func publishedDraftVideoLessonsResolvePlaybackURLs() async throws {
        await MockLearningStore.shared.deleteBlockedAICourses()
        let draft = makeDraftForTests(
            title: "AI Video Rendering Validation",
            summary: "Validate that all module video lessons resolve playback URLs.",
            outcomePrefix: "Render playable module videos",
            includeFindings: true
        )

        await MockLearningStore.shared.publishDraftToCatalog(draft)

        // Video assets are applied asynchronously; poll for completion.
        let deadline = Date().addingTimeInterval(8)
        var latestCourse: Course?
        while Date() < deadline {
            if let course = await MockLearningStore.shared.snapshotCourse(draft.id) {
                latestCourse = course
                let videoLessons = course.modules.flatMap(\.lessons).filter { $0.type == .video }
                let allResolved = !videoLessons.isEmpty && videoLessons.allSatisfy {
                    guard let url = $0.videoURL else { return false }
                    return url.hasPrefix("http")
                }
                if allResolved { break }
            }
            try await Task.sleep(nanoseconds: 300_000_000)
        }

        guard let course = latestCourse else {
            #expect(Bool(false), "Published course should be retrievable for video validation.")
            return
        }

        let videoLessons = course.modules.flatMap(\.lessons).filter { $0.type == .video }
        #expect(!videoLessons.isEmpty, "Expected at least one video lesson in generated module structure.")
        #expect(videoLessons.allSatisfy { ($0.videoURL ?? "").hasPrefix("http") })
        #expect(videoLessons.allSatisfy { ($0.subtitle ?? "").isEmpty == false })
    }

    @Test func generatedVideoAssetsContainModuleMediaMetadata() async throws {
        let draft = makeDraftForTests(
            title: "AI Media Metadata Validation",
            summary: "Validate script segments, YouTube companion hints, and audio readiness metadata.",
            outcomePrefix: "Verify media metadata quality",
            includeFindings: false
        )
        let generator = MockAIVideoGenerator()
        let generated = await generator.generateVideoAssets(for: draft) { _ in }

        #expect(!generated.isEmpty, "Expected generated video assets for video lessons.")

        for asset in generated.values {
            #expect((asset.youtubeCompanionURL ?? "").contains("youtube.com/results"))
            #expect(!(asset.youtubeSearchKeywords ?? []).isEmpty)
            #expect(!(asset.moduleScriptSegments ?? []).isEmpty)
            #expect((asset.tutorialNarrationText ?? "").contains("World Class Scholars"))
            #expect(!(asset.microphoneChecklist ?? []).isEmpty)
            #expect((asset.audioSystemStatus ?? "").isEmpty == false)
            #expect(
                (asset.openAIRecommendedPipeline ?? []).contains(where: { $0.contains("/v1/videos") })
            )
            #expect(
                (asset.openAIRecommendedPipeline ?? []).contains(where: { $0.contains("/v1/audio/speech") })
            )
        }
    }

}

private struct StubQuestionGenerator: AICourseGenerating {
    func generateDraft(prompt: String, createdBy: String, accessTier: AdminCourseAccessTier) async throws -> AdminCourseDraft {
        makeDraftForTests(
            title: "What is AI?",
            summary: "Question-style generated text.",
            outcomePrefix: "Understand AI basics",
            includeFindings: false
        )
    }
}

private func makeDraftForTests(
    title: String,
    summary: String,
    outcomePrefix: String,
    includeFindings: Bool
) -> AdminCourseDraft {
    let lessonVideo = AdminLessonDraft(
        id: UUID(),
        title: "Foundations video",
        kind: .video,
        durationMinutes: 20,
        notes: "Intro"
    )
    let lessonQuiz = AdminLessonDraft(
        id: UUID(),
        title: "Knowledge check",
        kind: .quiz,
        durationMinutes: 10,
        notes: "Quiz"
    )
    let lessonAssignment = AdminLessonDraft(
        id: UUID(),
        title: "Applied assignment",
        kind: .assignment,
        durationMinutes: 30,
        notes: "Assignment"
    )
    let module = AdminModuleDraft(
        id: UUID(),
        title: "Module 1",
        goals: ["Goal 1", "Goal 2"],
        lessons: [lessonVideo, lessonQuiz, lessonAssignment]
    )
    let findings: [AICourseReportFinding] = includeFindings ? [
        AICourseReportFinding(
            id: UUID(),
            title: "Delivery model fit",
            detail: "Weekly cohort is recommended.",
            confidence: 0.88
        )
    ] : []

    return AdminCourseDraft(
        id: UUID(),
        createdAt: Date(),
        updatedAt: Date(),
        createdBy: "admin@wcs",
        title: title,
        summary: summary,
        targetAudience: "Professionals",
        level: "Intermediate",
        durationWeeks: 8,
        outcomes: [
            "\(outcomePrefix) through structured implementation.",
            "Apply concepts to real workflows.",
            "Produce a capstone artifact."
        ],
        modules: [module],
        status: .readyForReview,
        accessTier: .freePublic,
        sourceReferences: ["OpenAlex API"],
        promotionalCopy: ["Launch your next learning milestone."],
        funnelPreview: nil,
        reasoningReport: AIReasoningReport(
            focusQuestion: "How should this course be structured?",
            assumptions: ["Structure improves outcomes."],
            reasoningSteps: [
                AIReasoningStep(
                    id: UUID(),
                    title: "Reasoning",
                    analysis: "Built module structure.",
                    evidence: ["OpenAlex API"]
                )
            ],
            conclusion: "Three-stage progression.",
            confidenceScore: 0.83
        ),
        researchTrace: AIResearchTrace(
            engineName: "WCS Engine",
            retrievalMode: "Hybrid",
            generatedQueries: ["ai operator curriculum"],
            evidenceCards: [
                AIEvidenceCard(
                    id: UUID(),
                    title: "Sample Source",
                    source: "OpenAlex",
                    snippet: "Evidence",
                    relevanceScore: 0.8,
                    freshnessScore: 0.8
                )
            ],
            qualityGate: AIQualityGate(
                passed: true,
                threshold: 0.7,
                score: 0.81,
                rationale: "Good evidence quality."
            ),
            citationMap: [
                AICitationMapping(
                    id: UUID(),
                    claim: "Course should have progressive modules.",
                    sourceTitle: "Sample Source",
                    sourceSystem: "OpenAlex"
                )
            ]
        ),
        cohortSelection: AICohortSelection(
            cohortType: .weeklyCohort,
            recommendedSize: 30,
            rationale: "Balanced facilitation and peer learning."
        ),
        reportFindings: findings
    )
}
