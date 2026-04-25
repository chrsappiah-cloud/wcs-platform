//
//  Subscription.swift
//  WCS-Platform
//

import Foundation

struct Subscription: Codable, Identifiable, Hashable {
    let id: UUID
    let planId: String
    let planName: String
    let status: SubscriptionStatus
    let startDate: Date
    let endDate: Date?
    let price: Decimal
}

enum SubscriptionStatus: String, Codable, Hashable {
    case active
    case pastDue
    case canceled
    case paused
}
