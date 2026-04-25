//
//  Discussion.swift
//  WCS-Platform
//

import Foundation

struct DiscussionTopic: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
}

struct DiscussionPost: Identifiable, Codable, Hashable {
    let id: UUID
    let authorName: String
    let authorRole: String
    let topicID: String
    let body: String
    let postedAt: Date
    var likeCount: Int
    var replyCount: Int
    var isPinned: Bool
}

struct DiscussionFeedResponse: Codable {
    let topics: [DiscussionTopic]
    let posts: [DiscussionPost]
}

struct DiscussionCreateRequest: Codable {
    let topicID: String
    let body: String
}

struct PipelineHealthStatus: Codable, Hashable {
    let apiReachable: Bool
    let middlewareReachable: Bool
    let realtimeReachable: Bool
    let databaseReachable: Bool
    let message: String
    let checkedAt: Date
}
