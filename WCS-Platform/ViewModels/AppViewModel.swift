//
//  AppViewModel.swift
//  WCS-Platform
//

import Combine
import Foundation

enum AppTab: String, Hashable {
    case discover
    case programs
    case discussion
    case profile
}

@MainActor
final class AppViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .discover
    @Published var selectedNavItem: String?
    @Published var isAuthenticated = false
    @Published var user: User?

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .wcsLearningStateDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.bootstrapUser() }
            }
            .store(in: &cancellables)
    }

    func navigate(to screen: String) {
        selectedNavItem = screen
    }

    func openTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func bootstrapUser() async {
        do {
            user = try await NetworkClient.shared.currentUser()
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            user = nil
        }
    }
}
