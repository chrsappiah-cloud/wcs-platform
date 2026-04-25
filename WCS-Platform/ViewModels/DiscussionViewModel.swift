//
//  DiscussionViewModel.swift
//  WCS-Platform
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject {
    @Published var topics: [DiscussionTopic] = []
    @Published var selectedTopicID: String?
    @Published var posts: [DiscussionPost] = []
    @Published var draftPost = ""
    @Published var isLoading = true
    @Published var isPosting = false
    @Published var pipelineStatus: PipelineHealthStatus?
    @Published var errorMessage: String?

    var canPost: Bool {
        !draftPost.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isPosting
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        do {
            async let feed = NetworkClient.shared.fetchDiscussionFeed(topicID: selectedTopicID)
            async let pipeline = NetworkClient.shared.fetchPipelineHealthStatus()
            let (resolvedFeed, resolvedPipeline) = try await (feed, pipeline)
            topics = resolvedFeed.topics
            posts = resolvedFeed.posts
            pipelineStatus = resolvedPipeline
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func selectTopic(_ id: String?) async {
        selectedTopicID = id
        await loadFeed()
    }

    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        do {
            let feed = try await NetworkClient.shared.fetchDiscussionFeed(topicID: selectedTopicID)
            topics = feed.topics
            posts = feed.posts
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func post(authorName: String) async {
        let message = draftPost.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        let topic = selectedTopicID ?? topics.first?.id ?? "announcements"
        isPosting = true
        errorMessage = nil
        defer { isPosting = false }

        do {
            _ = try await NetworkClient.shared.createDiscussionPost(topicID: topic, body: message, authorName: authorName)
            draftPost = ""
            await loadFeed()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
