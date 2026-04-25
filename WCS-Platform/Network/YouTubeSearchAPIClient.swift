//
//  YouTubeSearchAPIClient.swift
//  WCS-Platform
//
//  YouTube Data API v3 — https://developers.google.com/youtube/v3/docs/search/list
//  Set `YOUTUBE_DATA_API_KEY` in the Xcode scheme (Run → Environment Variables).
//

import Foundation

struct YouTubeVideoSnippet: Identifiable, Hashable, Sendable {
    var id: String { videoID }
    let videoID: String
    let title: String
    let thumbnailURL: URL?
}

struct YouTubeSearchConfiguration: Sendable {
    var regionCode: String?
    var relevanceLanguage: String?
    var order: String
    var safeSearch: String
    var videoEmbeddable: Bool

    static let `default` = YouTubeSearchConfiguration(
        regionCode: nil,
        relevanceLanguage: "en",
        order: "relevance",
        safeSearch: "strict",
        videoEmbeddable: true
    )

    static let wcsLearning = YouTubeSearchConfiguration(
        regionCode: nil,
        relevanceLanguage: "en",
        order: "relevance",
        safeSearch: "strict",
        videoEmbeddable: true
    )
}

struct YouTubeSearchPage: Sendable {
    let items: [YouTubeVideoSnippet]
    let nextPageToken: String?
}

enum YouTubeAPIError: Error, LocalizedError {
    case missingAPIKey
    case invalidRequestURL
    case httpStatus(code: Int, message: String?)
    case decodingFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "Set YOUTUBE_DATA_API_KEY in the scheme environment."
        case .invalidRequestURL:
            "Could not build the YouTube Data API request URL."
        case .httpStatus(let code, let message):
            message.map { "YouTube API error (\(code)): \($0)" } ?? "YouTube API error (\(code))."
        case .decodingFailed(let underlying):
            "Could not decode YouTube response: \(underlying.localizedDescription)"
        }
    }
}

private struct YouTubeSearchEnvelope: Decodable {
    struct Item: Decodable {
        struct IDBox: Decodable {
            let kind: String?
            let videoId: String?
        }

        let id: IDBox
        let snippet: Snippet?
    }

    struct Snippet: Decodable {
        let title: String?
        let thumbnails: Thumbnails?
    }

    struct Thumbnails: Decodable {
        struct Size: Decodable {
            let url: String?
        }

        let medium: Size?
        let high: Size?
    }

    let items: [Item]?
    let nextPageToken: String?
}

private struct YouTubeAPIErrorEnvelope: Decodable {
    struct Box: Decodable {
        let code: Int?
        let message: String?
        struct Err: Decodable {
            let message: String?
        }

        let errors: [Err]?
    }

    let error: Box?
}

enum YouTubeSearchAPIClient {
    nonisolated static func resolveAPIKey() -> String? {
        if let env = ProcessInfo.processInfo.environment["YOUTUBE_DATA_API_KEY"],
           !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    static func searchVideos(
        query: String,
        configuration: YouTubeSearchConfiguration? = nil,
        pageToken: String? = nil,
        maxResults: Int = 8,
        session: URLSession = .shared
    ) async throws -> YouTubeSearchPage {
        let configuration = configuration ?? .wcsLearning
        guard let apiKey = resolveAPIKey() else {
            throw YouTubeAPIError.missingAPIKey
        }

        var components = URLComponents(string: "https://www.googleapis.com/youtube/v3/search")!
        var items: [URLQueryItem] = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(max(1, min(maxResults, 50)))"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "order", value: configuration.order),
            URLQueryItem(name: "safeSearch", value: configuration.safeSearch),
        ]
        if configuration.videoEmbeddable {
            items.append(URLQueryItem(name: "videoEmbeddable", value: "true"))
        }
        if let region = configuration.regionCode, !region.isEmpty {
            items.append(URLQueryItem(name: "regionCode", value: region.uppercased()))
        }
        if let lang = configuration.relevanceLanguage, !lang.isEmpty {
            items.append(URLQueryItem(name: "relevanceLanguage", value: lang))
        }
        if let pageToken, !pageToken.isEmpty {
            items.append(URLQueryItem(name: "pageToken", value: pageToken))
        }
        components.queryItems = items

        guard let url = components.url else {
            throw YouTubeAPIError.invalidRequestURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw YouTubeAPIError.httpStatus(code: -1, message: nil)
        }

        guard (200 ..< 300).contains(http.statusCode) else {
            let message = Self.decodeYouTubeErrorMessage(from: data) ?? String(data: data, encoding: .utf8)
            throw YouTubeAPIError.httpStatus(code: http.statusCode, message: message)
        }

        let decoded: YouTubeSearchEnvelope
        do {
            decoded = try JSONDecoder().decode(YouTubeSearchEnvelope.self, from: data)
        } catch {
            throw YouTubeAPIError.decodingFailed(underlying: error)
        }

        let snippets: [YouTubeVideoSnippet] = (decoded.items ?? []).compactMap { item in
            guard let videoID = item.id.videoId else { return nil }
            let title = item.snippet?.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Video"
            let urlString = item.snippet?.thumbnails?.high?.url
                ?? item.snippet?.thumbnails?.medium?.url
            let thumb = urlString.flatMap(URL.init(string:))
            return YouTubeVideoSnippet(videoID: videoID, title: title, thumbnailURL: thumb)
        }

        return YouTubeSearchPage(items: snippets, nextPageToken: decoded.nextPageToken)
    }

    private static func decodeYouTubeErrorMessage(from data: Data) -> String? {
        guard let env = try? JSONDecoder().decode(YouTubeAPIErrorEnvelope.self, from: data) else {
            return nil
        }
        if let first = env.error?.errors?.first?.message, !first.isEmpty {
            return first
        }
        return env.error?.message
    }
}
