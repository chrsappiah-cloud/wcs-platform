//
//  MembershipPaymentsHubView.swift
//  WCS-Platform
//
//  Deep-links to hosted card checkout and merchant dashboards. Card capture belongs to your PSP or StoreKit.
//

import SwiftUI

struct MembershipPaymentsHubView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    private let links = BrandOutboundLinks.current

    var body: some View {
        List {
            Section {
                Text(
                    "WCS routes learners and administrators to your payment processor (for example Stripe Checkout + Connect, or Apple In-App Purchase for eligible digital goods). "
                        + "Configure HTTPS URLs below; the app never collects raw PAN data."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Section("Membership & subscriptions") {
                if let url = links.membershipCardCheckoutURL {
                    Link("Open hosted membership checkout", destination: url)
                } else {
                    Text("Set STRIPE_MEMBERSHIP_CHECKOUT_URL in the run scheme to enable card checkout in Safari.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let url = links.appleSubscriptionsMarketingURL {
                    Link("Apple In-App Purchase overview", destination: url)
                }
            }

            Section("Administrator payouts") {
                if appViewModel.user != nil {
                    if let url = links.merchantFinancialDashboardURL {
                        Link("Open merchant / Connect dashboard", destination: url)
                    } else {
                        Text("Set ADMIN_MERCHANT_DASHBOARD_URL to your Stripe (or PSP) dashboard for settlement routing.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Sign in to show administrator payout shortcuts.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Membership & payouts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MembershipPaymentsHubView()
            .environmentObject(AppViewModel())
    }
}
