//
//  YouTubeEmbedWebView.swift
//  WCS-Platform
//

import SwiftUI
import WebKit

struct YouTubeEmbedWebView: UIViewRepresentable {
    let videoID: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        return WKWebView(frame: .zero, configuration: configuration)
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let safeID = Self.sanitizedVideoID(videoID) else { return }
        guard context.coordinator.lastID != safeID else { return }
        context.coordinator.lastID = safeID
        let html = """
        <!DOCTYPE html><html><head><meta name=viewport content="width=device-width, initial-scale=1">
        <style>body{margin:0;background:#000}iframe{border:0;width:100%;height:100%;position:absolute;top:0;left:0}</style>
        </head><body>
        <iframe src="https://www.youtube.com/embed/\(safeID)?playsinline=1&modestbranding=1" \
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" \
        allowfullscreen></iframe>
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }

    private static func sanitizedVideoID(_ raw: String) -> String? {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
        guard raw.count == 11, raw.unicodeScalars.allSatisfy({ allowed.contains($0) }) else { return nil }
        return raw
    }

    final class Coordinator: NSObject {
        var lastID: String?
    }
}
