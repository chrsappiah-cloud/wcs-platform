//
//  Assignment.swift
//  WCS-Platform
//

import Foundation

struct Assignment: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let dueDate: Date?
    let maxAttempts: Int
    let isSubmitted: Bool
    let submission: Submission?
}

struct Submission: Codable, Hashable {
    let id: UUID
    let content: String?
    let attachments: [URL]
    let submittedAt: Date
    let feedback: String?
    let grade: Int?
}

struct AssignmentSubmissionRequest: Codable {
    let assignmentId: UUID
    let content: String?
    let attachments: [String]
}
