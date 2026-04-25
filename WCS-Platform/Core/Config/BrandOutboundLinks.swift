//
//  BrandOutboundLinks.swift
//  WCS-Platform
//
//  Social, hosted checkout, and merchant dashboard URLs via environment variables (scheme / CI).
//

import Foundation

struct BrandOutboundLinks: Sendable {
    let instagramURL: URL?
    let tiktokURL: URL?
    let facebookURL: URL?
    let xURL: URL?
    let youtubeChannelURL: URL?
    let linkedInURL: URL?
    let membershipCardCheckoutURL: URL?
    let merchantFinancialDashboardURL: URL?
    let appleSubscriptionsMarketingURL: URL?

    static let current: BrandOutboundLinks = {
        func envURL(_ key: String) -> URL? {
            guard let raw = ProcessInfo.processInfo.environment[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !raw.isEmpty,
                  let url = URL(string: raw),
                  let scheme = url.scheme?.lowercased(),
                  scheme == "https" || scheme == "http"
            else { return nil }
            return url
        }

        return BrandOutboundLinks(
            instagramURL: envURL("SOCIAL_INSTAGRAM_URL"),
            tiktokURL: envURL("SOCIAL_TIKTOK_URL"),
            facebookURL: envURL("SOCIAL_FACEBOOK_URL"),
            xURL: envURL("SOCIAL_X_URL"),
            youtubeChannelURL: envURL("SOCIAL_YOUTUBE_CHANNEL_URL"),
            linkedInURL: envURL("SOCIAL_LINKEDIN_URL"),
            membershipCardCheckoutURL: envURL("STRIPE_MEMBERSHIP_CHECKOUT_URL"),
            merchantFinancialDashboardURL: envURL("ADMIN_MERCHANT_DASHBOARD_URL"),
            appleSubscriptionsMarketingURL: envURL("APPLE_IAP_GUIDE_URL")
                ?? URL(string: "https://developer.apple.com/in-app-purchase/")
        )
    }()

    var socialPairs: [(label: String, url: URL)] {
        var out: [(String, URL)] = []
        if let instagramURL { out.append(("Instagram", instagramURL)) }
        if let tiktokURL { out.append(("TikTok", tiktokURL)) }
        if let facebookURL { out.append(("Facebook", facebookURL)) }
        if let xURL { out.append(("X", xURL)) }
        if let youtubeChannelURL { out.append(("YouTube", youtubeChannelURL)) }
        if let linkedInURL { out.append(("LinkedIn", linkedInURL)) }
        return out
    }
}
