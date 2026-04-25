//
//  ModuleVideoDiscoveryPipeline.swift
//  WCS-Platform
//
//  Maps course/module/lesson scripts to live YouTube search + embeds (companion to catalog `videoURL` and admin `MockAIVideoGenerator`).
//

import Foundation

/// A lesson line used for external video discovery (catalog `Course` / `Lesson`).
struct LessonVideoScriptLine: Identifiable, Hashable, Sendable {
    let id: UUID
    let courseTitle: String
    let moduleTitle: String
    let lessonTitle: String
    let lessonSubtitle: String?

    var youTubeSearchQuery: String {
        let focus = [lessonTitle, lessonSubtitle].compactMap(\.self).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let joined = focus.joined(separator: " ")
        return "\(courseTitle) \(moduleTitle) \(joined) online course lecture documentary".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Same pipeline for administrator drafts prior to publish.
struct AdminLessonVideoScriptLine: Identifiable, Hashable, Sendable {
    let id: UUID
    let draftTitle: String
    let moduleTitle: String
    let lessonTitle: String
    let lessonNotes: String

    var youTubeSearchQuery: String {
        let note = lessonNotes.split(whereSeparator: \.isNewline).first.map(String.init) ?? ""
        let cue = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if cue.isEmpty {
            return "\(draftTitle) \(moduleTitle) \(lessonTitle) curriculum walkthrough tutorial"
        }
        return "\(draftTitle) \(moduleTitle) \(lessonTitle) \(cue)"
    }
}

struct LessonVideoDiscoveryResult: Identifiable, Hashable, Sendable {
    let scriptLine: LessonVideoScriptLine
    let snippets: [YouTubeVideoSnippet]

    var id: UUID { scriptLine.id }
}

struct AdminLessonVideoDiscoveryResult: Identifiable, Hashable, Sendable {
    let scriptLine: AdminLessonVideoScriptLine
    let snippets: [YouTubeVideoSnippet]

    var id: UUID { scriptLine.id }
}

enum ModuleVideoDiscoveryPipeline {
    /// Builds one script line per **video** lesson in display order.
    static func scriptLines(from course: Course) -> [LessonVideoScriptLine] {
        let sortedModules = course.modules.sorted { $0.order < $1.order }
        var lines: [LessonVideoScriptLine] = []
        for module in sortedModules {
            for lesson in module.lessons where lesson.type == .video {
                lines.append(
                    LessonVideoScriptLine(
                        id: lesson.id,
                        courseTitle: course.title,
                        moduleTitle: module.title,
                        lessonTitle: lesson.title,
                        lessonSubtitle: lesson.subtitle
                    )
                )
            }
        }
        return lines
    }

    static func adminScriptLines(from draft: AdminCourseDraft) -> [AdminLessonVideoScriptLine] {
        var lines: [AdminLessonVideoScriptLine] = []
        for module in draft.modules {
            for lesson in module.lessons where lesson.kind == .video || lesson.kind == .live {
                lines.append(
                    AdminLessonVideoScriptLine(
                        id: lesson.id,
                        draftTitle: draft.title,
                        moduleTitle: module.title,
                        lessonTitle: lesson.title,
                        lessonNotes: lesson.notes
                    )
                )
            }
        }
        return lines
    }

    static func resolveCompanionVideos(
        scriptLines: [LessonVideoScriptLine],
        maxResultsPerLesson: Int = 2,
        configuration: YouTubeSearchConfiguration = .wcsLearning,
        session: URLSession = .shared
    ) async throws -> [LessonVideoDiscoveryResult] {
        guard YouTubeSearchAPIClient.resolveAPIKey() != nil else {
            throw YouTubeAPIError.missingAPIKey
        }
        var results: [LessonVideoDiscoveryResult] = []
        results.reserveCapacity(scriptLines.count)
        for line in scriptLines {
            let page = try await YouTubeSearchAPIClient.searchVideos(
                query: line.youTubeSearchQuery,
                configuration: configuration,
                maxResults: maxResultsPerLesson,
                session: session
            )
            results.append(LessonVideoDiscoveryResult(scriptLine: line, snippets: page.items))
        }
        return results
    }

    static func resolveAdminDraftVideos(
        scriptLines: [AdminLessonVideoScriptLine],
        maxResultsPerLesson: Int = 2,
        configuration: YouTubeSearchConfiguration = .wcsLearning,
        session: URLSession = .shared
    ) async throws -> [AdminLessonVideoDiscoveryResult] {
        guard YouTubeSearchAPIClient.resolveAPIKey() != nil else {
            throw YouTubeAPIError.missingAPIKey
        }
        var results: [AdminLessonVideoDiscoveryResult] = []
        results.reserveCapacity(scriptLines.count)
        for line in scriptLines {
            let page = try await YouTubeSearchAPIClient.searchVideos(
                query: line.youTubeSearchQuery,
                configuration: configuration,
                maxResults: maxResultsPerLesson,
                session: session
            )
            results.append(AdminLessonVideoDiscoveryResult(scriptLine: line, snippets: page.items))
        }
        return results
    }
}
