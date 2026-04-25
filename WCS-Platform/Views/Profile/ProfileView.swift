//
//  ProfileView.swift
//  WCS-Platform
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var pipelineStatus: PipelineHealthStatus?
    @State private var isCheckingPipeline = false

    var body: some View {
        List {
            Section {
                if let user = appViewModel.user {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(DesignTokens.brandMuted)
                                .frame(width: 56, height: 56)
                            Text(String(user.name.prefix(1)).uppercased())
                                .font(.title2.weight(.bold))
                                .foregroundStyle(DesignTokens.brand)
                        }
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(user.name)
                                .font(.headline.weight(.semibold))
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, DesignTokens.Spacing.xs)

                    LabeledContent("Premium", value: user.isPremium ? "Active" : "Not active")
                } else {
                    Text("Sign-in will connect to your identity provider and populate this profile.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Account")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            Section {
                if let enrollments = appViewModel.user?.enrollments, !enrollments.isEmpty {
                    ForEach(enrollments) { enrollment in
                        NavigationLink {
                            CourseDetailView(courseId: enrollment.courseId)
                        } label: {
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                                Text(MockCourseCatalog.displayTitle(for: enrollment.courseId))
                                    .font(.subheadline.weight(.semibold))
                                ProgressView(value: enrollment.progressPercentage)
                                    .tint(DesignTokens.brandAccent)
                                Text(enrollment.progressPercentage, format: .percent.precision(.fractionLength(0)))
                                    .font(.caption2.weight(.medium).monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, DesignTokens.Spacing.xs)
                        }
                    }
                } else {
                    Text("Enroll from a program page to see it here with live progress.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("My programs")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            Section {
                SubscriptionBadgeView(subscriptions: appViewModel.user?.subscriptions ?? [])
            } header: {
                Text("Subscriptions")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }

            Section {
                Toggle("Use mock API", isOn: Binding(
                    get: { NetworkClient.shared.useMocks },
                    set: { newValue in
                        NetworkClient.shared.useMocks = newValue
                        Task { @MainActor in
                            NotificationCenter.default.post(name: .wcsLearningStateDidChange, object: nil)
                            await appViewModel.bootstrapUser()
                        }
                    }
                ))
                if NetworkClient.shared.useMocks {
                    Toggle("Mock premium mode", isOn: Binding(
                        get: { UserDefaults.standard.bool(forKey: "wcs.mockPremiumMode") },
                        set: { newValue in
                            UserDefaults.standard.set(newValue, forKey: "wcs.mockPremiumMode")
                            Task { @MainActor in
                                NotificationCenter.default.post(name: .wcsLearningStateDidChange, object: nil)
                                await appViewModel.bootstrapUser()
                            }
                        }
                    ))
                }
                Toggle("Debug safe mode (simulator)", isOn: Binding(
                    get: { AppEnvironment.debugSafeMode },
                    set: { newValue in
                        AppEnvironment.setDebugSafeMode(newValue)
                        Task { @MainActor in
                            NotificationCenter.default.post(name: .wcsLearningStateDidChange, object: nil)
                        }
                    }
                ))
                NavigationLink {
                    AdminCourseCreatorView()
                } label: {
                    Label("WCS AI Course Generation", systemImage: "lock.shield")
                }
                Button {
                    Task { await checkPipeline() }
                } label: {
                    if isCheckingPipeline {
                        ProgressView()
                    } else {
                        Label("Check API Pipeline", systemImage: "dot.radiowaves.up.forward")
                    }
                }
                if let status = pipelineStatus {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API: \(status.apiReachable ? "online" : "offline") · Middleware: \(status.middlewareReachable ? "online" : "offline")")
                        Text("Realtime: \(status.realtimeReachable ? "online" : "offline") · Database: \(status.databaseReachable ? "online" : "offline")")
                        Text(status.message)
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption2)
                }
                LabeledContent("API base") {
                    Text(AppEnvironment.platformAPIBaseURL.absoluteString)
                        .font(.caption2)
                        .simulatorStableTextSelection()
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("Developer")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            } footer: {
                Text("Set WCSPlatformAPIBaseURL in Info.plist. Live mode uses the same NetworkClient entry points.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .task {
            await appViewModel.bootstrapUser()
        }
    }

    private func checkPipeline() async {
        isCheckingPipeline = true
        defer { isCheckingPipeline = false }
        pipelineStatus = try? await NetworkClient.shared.fetchPipelineHealthStatus()
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppViewModel())
    }
}
