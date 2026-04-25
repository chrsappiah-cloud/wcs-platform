//
//  CourseListView.swift
//  WCS-Platform
//

import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel = CourseListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.courses.isEmpty {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(DesignTokens.brandAccent)
                    Text("Loading programs…")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.lastError {
                ContentUnavailableView(
                    "Couldn’t load programs",
                    systemImage: "wifi.exclamationmark",
                    description: Text(error.localizedDescription)
                )
            } else if viewModel.courses.isEmpty {
                ContentUnavailableView(
                    "No programs yet",
                    systemImage: "rectangle.stack.badge.plus",
                    description: Text("Turn on “Use mock API” in Profile, or set WCSPlatformAPIBaseURL in Info.plist to your backend.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: DesignTokens.Spacing.lg) {
                        if !viewModel.searchText.isEmpty, viewModel.filteredCourses.isEmpty {
                            ContentUnavailableView {
                                Label("No matches", systemImage: "magnifyingglass")
                            } description: {
                                Text("Try a different program name, partner, or topic.")
                            }
                            .padding(.top, DesignTokens.Spacing.xxl)
                        }
                        ForEach(viewModel.filteredCourses) { course in
                            NavigationLink(value: course.id) {
                                CourseCardView(course: course)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.md)
                }
            }
        }
        .wcsGroupedScreen()
        .navigationDestination(for: UUID.self) { id in
            CourseDetailView(courseId: id)
        }
        .navigationTitle("Programs")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search programs, partners, topics"
        )
        .refreshable {
            await viewModel.loadAvailableCourses()
        }
        .task {
            await viewModel.loadAvailableCourses()
        }
        .onReceive(NotificationCenter.default.publisher(for: .wcsLearningStateDidChange)) { _ in
            guard !AppEnvironment.debugSafeMode else { return }
            Task { await viewModel.loadAvailableCourses() }
        }
    }
}

#Preview {
    NavigationStack {
        CourseListView()
    }
}
