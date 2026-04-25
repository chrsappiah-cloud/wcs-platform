//
//  DesignTokens.swift
//  WCS-Platform
//

import SwiftUI

/// WCS learner app visual system: spacing, radii, brand color, and surfaces tuned for clarity on iPhone.
enum DesignTokens {
    static let brand = Color(red: 0.07, green: 0.22, blue: 0.42)
    static let brandMuted = Color(red: 0.07, green: 0.22, blue: 0.42).opacity(0.12)
    static let brandAccent = Color(red: 0.62, green: 0.12, blue: 0.20)
    static let brandAccentSubtle = Color(red: 0.62, green: 0.12, blue: 0.20).opacity(0.14)

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 22
    }

    static let heroGradient = LinearGradient(
        colors: [Color.black.opacity(0.62), Color.black.opacity(0.18), Color.clear],
        startPoint: .bottom,
        endPoint: .top
    )

    static let subtleBorder = Color.primary.opacity(0.06)
}

// MARK: - View polish

extension View {
    /// Standard scroll screen background.
    func wcsGroupedScreen() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    /// Primary elevated surface (cards, resume tiles).
    func wcsElevatedSurface(cornerRadius: CGFloat = DesignTokens.Radius.lg) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
        }
    }

    /// Inset panel inside a screen (capability list, meta blocks).
    func wcsInsetPanel(cornerRadius: CGFloat = DesignTokens.Radius.lg) -> some View {
        padding(DesignTokens.Spacing.lg)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(DesignTokens.subtleBorder, lineWidth: 1)
            }
    }

    func wcsSectionTitle() -> some View {
        font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }
}


struct WCSInteractiveCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .brightness(configuration.isPressed ? -0.015 : 0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

extension View {
    func wcsInteractiveCard() -> some View {
        buttonStyle(WCSInteractiveCardButtonStyle())
    }
}
