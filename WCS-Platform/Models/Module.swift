//
//  Module.swift
//  WCS-Platform
//

import Foundation

struct Module: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let order: Int
    let isAvailable: Bool
    let isUnlocked: Bool
    let lessons: [Lesson]
}
