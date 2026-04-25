//
//  AdminAIVideoGenerator.swift
//  WCS-Platform
//

import Foundation

struct GeneratedVideoAsset: Codable, Hashable {
    let lessonId: UUID
    let title: String
    let playbackURL: String
    let scriptOutline: String
    let productionNotes: String
    let confidence: Double
    let generatedAt: Date
}

protocol AIVideoGenerating {
    func cachedVideoAssets(for draft: AdminCourseDraft) async -> [UUID: GeneratedVideoAsset]
    func generateVideoAssets(
        for draft: AdminCourseDraft,
        onAssetGenerated: @escaping @Sendable (GeneratedVideoAsset) -> Void
    ) async -> [UUID: GeneratedVideoAsset]
    func clearCachedVideoAssets(for courseID: UUID) async
}

struct MockAIVideoGenerator: AIVideoGenerating {
    private let cache = GeneratedVideoAssetCache()
    nonisolated init() {}

    private let sampleVideoURLs = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"
    ]

    func cachedVideoAssets(for draft: AdminCourseDraft) async -> [UUID: GeneratedVideoAsset] {
        await cache.assets(for: draft.id)
    }

    func generateVideoAssets(
        for draft: AdminCourseDraft,
        onAssetGenerated: @escaping @Sendable (GeneratedVideoAsset) -> Void
    ) async -> [UUID: GeneratedVideoAsset] {
        var assets = await cache.assets(for: draft.id)
        var seed = 0

        for module in draft.modules {
            for lesson in module.lessons where lesson.kind == .video || lesson.kind == .live {
                if let existing = assets[lesson.id] {
                    onAssetGenerated(existing)
                    continue
                }

                // Simulate progressive real-time generation work for each lesson.
                try? await Task.sleep(nanoseconds: 600_000_000)

                let sourceHint = draft.sourceReferences.first ?? "internal curriculum guidance"
                let url = sampleVideoURLs[stableIndex(for: lesson.id, offset: seed) % sampleVideoURLs.count]
                seed += 1

                let asset = GeneratedVideoAsset(
                    lessonId: lesson.id,
                    title: lesson.title,
                    playbackURL: url,
                    scriptOutline: """
                    1) Hook and context for \(draft.title)
                    2) Core concept walkthrough for \(module.title)
                    3) Worked example and learner checkpoint
                    4) Summary and next action
                    """,
                    productionNotes: "AI-generated in real time and archived for replay. Source grounding: \(sourceHint).",
                    confidence: draft.sourceReferences.isEmpty ? 0.65 : 0.86,
                    generatedAt: Date()
                )
                assets[lesson.id] = asset
                await cache.upsert(asset: asset, for: draft.id)
                onAssetGenerated(asset)
            }
        }

        return assets
    }

    private func stableIndex(for id: UUID, offset: Int) -> Int {
        let sum = id.uuidString.unicodeScalars.reduce(0) { partial, scalar in
            partial + Int(scalar.value)
        }
        return sum + offset
    }

    func clearCachedVideoAssets(for courseID: UUID) async {
        await cache.removeAssets(for: courseID)
    }
}

private actor GeneratedVideoAssetCache {
    private let storageKey = "wcs.generatedVideoAssetsByCourse"
    private var assetsByCourse: [UUID: [UUID: GeneratedVideoAsset]] = [:]
    private var hasLoaded = false

    func assets(for courseId: UUID) -> [UUID: GeneratedVideoAsset] {
        loadIfNeeded()
        return assetsByCourse[courseId] ?? [:]
    }

    func upsert(asset: GeneratedVideoAsset, for courseId: UUID) {
        loadIfNeeded()
        var courseAssets = assetsByCourse[courseId] ?? [:]
        courseAssets[asset.lessonId] = asset
        assetsByCourse[courseId] = courseAssets
        persist()
    }

    func removeAssets(for courseId: UUID) {
        loadIfNeeded()
        assetsByCourse.removeValue(forKey: courseId)
        persist()
    }

    private func loadIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([String: [GeneratedVideoAsset]].self, from: data) {
            assetsByCourse = decoded.reduce(into: [:]) { partialResult, entry in
                guard let courseId = UUID(uuidString: entry.key) else { return }
                partialResult[courseId] = Dictionary(uniqueKeysWithValues: entry.value.map { ($0.lessonId, $0) })
            }
        }
    }

    private func persist() {
        let encodable = assetsByCourse.reduce(into: [String: [GeneratedVideoAsset]]()) { partialResult, entry in
            partialResult[entry.key.uuidString] = Array(entry.value.values)
        }
        if let data = try? JSONEncoder().encode(encodable) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
