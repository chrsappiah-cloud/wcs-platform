//
//  Enrollment.swift
//  WCS-Platform
//

import Foundation

struct Enrollment: Codable, Identifiable, Hashable {
    let id: UUID
    let courseId: UUID
    let userId: UUID
    let startDate: Date
    let endDate: Date?
    let status: EnrollmentStatus
    let progressPercentage: Double
}

enum EnrollmentStatus: String, Codable, Hashable {
    case active
    case completed
    case dropped
}
