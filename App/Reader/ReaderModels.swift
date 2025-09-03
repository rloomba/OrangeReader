import Foundation

struct ReaderArticle: Identifiable, Codable, Hashable {
    var id: String { url.absoluteString }
    let url: URL
    let title: String
    let contentHTML: String
    let extractedAt: Date
}

