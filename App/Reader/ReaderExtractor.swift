import Foundation
#if canImport(Readability)
import Readability
#endif

actor ReaderCache {
    static let shared = ReaderCache()
    private let directory: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("ReaderCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func key(for url: URL, variant: String?) -> String {
        // Simple hash
        let str = url.absoluteString + (variant ?? "")
        let data = Data(str.utf8)
        return data.base64EncodedString().replacingOccurrences(of: "/", with: "_")
    }

    func load(url: URL, variant: String?) -> ReaderArticle? {
        let file = directory.appendingPathComponent(key(for: url, variant: variant) + ".json")
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder().decode(ReaderArticle.self, from: data)
    }

    func save(_ article: ReaderArticle, variant: String?) {
        let file = directory.appendingPathComponent(key(for: article.url, variant: variant) + ".json")
        if let data = try? JSONEncoder().encode(article) {
            try? data.write(to: file, options: .atomic)
        }
    }

    func clear() {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
        for url in contents { try? FileManager.default.removeItem(at: url) }
    }
}

@MainActor
final class ReaderExtractor {
    static let shared = ReaderExtractor()
    private init() {}

    func extract(from url: URL, cache: Bool = true, allowImages: Bool) async -> ReaderArticle? {
        let variant = allowImages ? "img_on" : "img_off"
        if cache, let cached = await ReaderCache.shared.load(url: url, variant: variant) { return cached }
        guard let (title, content) = await parseWithReadability(url: url) else { return nil }
        let article = ReaderArticle(url: url, title: title.isEmpty ? (url.host ?? "") : title, contentHTML: wrapHTML(body: content, allowImages: allowImages), extractedAt: Date())
        await ReaderCache.shared.save(article, variant: variant)
        return article
    }

    nonisolated func extractWithTimeout(from url: URL, allowImages: Bool, timeout seconds: Double = 8) async -> ReaderArticle? {
        await withTaskGroup(of: ReaderArticle?.self) { group in
            group.addTask { [weak self] in
                guard let self else { return nil }
                return await self.extract(from: url, cache: true, allowImages: allowImages)
            }
            group.addTask {
                let ns = UInt64(max(0, seconds) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: ns)
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
    }

    private func parseWithReadability(url: URL) async -> (String, String)? {
        #if canImport(Readability)
        do {
            let readability: Readability = await MainActor.run { Readability() }
            let result = try await readability.parse(url: url, options: nil)
            let title = result.title ?? (url.host ?? "")
            let content = result.content ?? ""
            if content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty { return nil }
            return (title, content)
        } catch {
            return nil
        }
        #else
        return nil
        #endif
    }

    private func wrapHTML(body: String, allowImages: Bool) -> String {
        return """
        <!doctype html>
        <html>
        <head>
          <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
          <meta name=\"color-scheme\" content=\"light dark\">
          <style>
            :root { --base: 17px; --fg: #1C1C1E; --accent: #0066CC; }
            @media (prefers-color-scheme: dark) { :root { --fg: rgb(229,229,234); --accent: #4da3ff; } }
            html, body { margin: 0; padding: 16px; -webkit-text-size-adjust: 100%; background: transparent; color: var(--fg); }
            /* Neutralize site-specific washes */
            body, body * { color: var(--fg) !important; background: transparent !important; opacity: 1 !important; mix-blend-mode: normal !important; }
            a { color: var(--accent) !important; text-decoration: none; }
            /* Keep images hidden per app preference */
            \(allowImages ? "" : "img, picture, video, figure { display: none !important; }")
          </style>
        </head>
        <body>
          \(body)
        </body>
        </html>
        """
    }
}
