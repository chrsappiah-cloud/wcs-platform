//
//  Lesson.swift
//  WCS-Platform
//

import Foundation

struct Lesson: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String?
    let type: LessonType
    let videoURL: String?
    let durationSeconds: Int
    let isCompleted: Bool
    let isAvailable: Bool
    let isUnlocked: Bool
    let reading: ReadingContent?
    let quiz: Quiz?
    let assignment: Assignment?
}

enum LessonType: String, Codable, Hashable {
    case video
    case reading
    case quiz
    case assignment
}

struct ReadingContent: Codable, Hashable {
    let markdown: String
}
