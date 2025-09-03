import Foundation

struct HNItem: Codable, Identifiable, Hashable {
    let id: Int
    let type: String?
    let by: String?
    let time: TimeInterval?
    let text: String?
    let dead: Bool?
    let deleted: Bool?
    let parent: Int?
    let kids: [Int]?
    let url: String?
    let score: Int?
    let title: String?
    let descendants: Int?
}

struct HNUser: Codable, Hashable {
    let id: String
    let created: TimeInterval
    let karma: Int
    let about: String?
    let submitted: [Int]?
}

