//
//  DiscussionView.swift
//  WCS-Platform
//

import SwiftUI

struct DiscussionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = DiscussionViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                ProgressView("Loading discussion...")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        header
                        composer
                        feed
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
            }
        }
        .wcsGroupedScreen()
        .navigationTitle("Discussion")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .task { await viewModel.loadAll() }
        .refreshable { await viewModel.loadAll() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Community learning room")
                .font(.title3.weight(.bold))
            Text("Join learner threads, ask staff questions, and stay updated with cohort announcements.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    topicChip("All", id: nil)
                    ForEach(viewModel.topics) { topic in
                        topicChip(topic.title, id: topic.id)
                    }
                }
            }

            if let pipeline = viewModel.pipelineStatus {
                HStack(spacing: 8) {
                    Image(systemName: pipeline.databaseReachable ? "dot.radiowaves.up.forward" : "exclamationmark.triangle.fill")
                        .foregroundStyle(pipeline.databaseReachable ? .green : .orange)
                    Text("Pipeline: API \(statusWord(pipeline.apiReachable)) · Middleware \(statusWord(pipeline.middlewareReachable)) · Realtime \(statusWord(pipeline.realtimeReachable)) · DB \(statusWord(pipeline.databaseReachable))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .wcsInsetPanel()
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Start a thread")
                .font(.headline.weight(.semibold))

            TextEditor(text: $viewModel.draftPost)
                .frame(minHeight: 96)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(AppEnvironment.simulatorStabilityMode ? .never : .sentences)
                .simulatorStableTextSelection()
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                Task { await viewModel.post(authorName: appViewModel.user?.name ?? "WCS Learner") }
            } label: {
                if viewModel.isPosting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Label("Publish discussion post", systemImage: "paperplane.fill")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.brandAccent)
            .disabled(!viewModel.canPost)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .wcsInsetPanel()
    }

    private var feed: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Active threads")
                .wcsSectionTitle()
            if viewModel.posts.isEmpty {
                ContentUnavailableView(
                    "No discussion posts yet",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Create the first post for this topic.")
                )
            } else {
                ForEach(viewModel.posts) { post in
                    NavigationLink {
                        DiscussionThreadDetailView(post: post)
                    } label: {
                        DiscussionPostCard(post: post, topicTitle: topicTitle(post.topicID))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func topicChip(_ title: String, id: String?) -> some View {
        let isSelected = viewModel.selectedTopicID == id
        return Button(title) {
            Task { await viewModel.selectTopic(id) }
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isSelected ? DesignTokens.brandAccentSubtle : Color(.tertiarySystemFill), in: Capsule())
        .foregroundStyle(isSelected ? DesignTokens.brandAccent : .secondary)
    }

    private func topicTitle(_ id: String) -> String {
        viewModel.topics.first(where: { $0.id == id })?.title ?? "General"
    }

    private func statusWord(_ value: Bool) -> String {
        value ? "online" : "offline"
    }
}

private struct DiscussionPostCard: View {
    let post: DiscussionPost
    let topicTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text(topicTitle)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                if post.isPinned {
                    Label("Pinned", systemImage: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(DesignTokens.brandAccent)
                }
                Spacer()
                Text(post.postedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("\(post.authorName) · \(post.authorRole)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(post.likeCount)", systemImage: "hand.thumbsup")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Label("\(post.replyCount)", systemImage: "bubble.left")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .wcsInsetPanel()
    }
}

private struct DiscussionThreadDetailView: View {
    let post: DiscussionPost

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                DiscussionPostCard(post: post, topicTitle: "Thread")
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Thread details")
                        .wcsSectionTitle()
                    Text("This thread view is fully connected in routing. Integrate your backend reply endpoint to load nested replies in real-time.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .wcsInsetPanel()
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .wcsGroupedScreen()
        .navigationTitle("Thread")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DiscussionView()
            .environmentObject(AppViewModel())
    }
}
