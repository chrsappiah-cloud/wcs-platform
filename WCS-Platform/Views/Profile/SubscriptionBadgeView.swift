//
//  SubscriptionBadgeView.swift
//  WCS-Platform
//

import SwiftUI

struct SubscriptionBadgeView: View {
    let subscriptions: [Subscription]

    var body: some View {
        if subscriptions.isEmpty {
            Text("No active subscriptions")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(subscriptions) { sub in
                    HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(sub.planName)
                                .font(.subheadline.weight(.semibold))
                            Text(sub.status.rawValue.capitalized)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(.tertiarySystemFill)))
                        }
                        Spacer(minLength: 0)
                        Text(sub.price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(DesignTokens.brand)
                    }
                    .padding(DesignTokens.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                            .strokeBorder(DesignTokens.subtleBorder, lineWidth: 1)
                    }
                }
            }
        }
    }
}

#Preview {
    SubscriptionBadgeView(subscriptions: [])
        .padding()
}
