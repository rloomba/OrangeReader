import Foundation

enum FeedType: String, CaseIterable, Identifiable {
    case top
    case new
    case best
    case ask
    case show
    case jobs

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .top: return "Top"
        case .new: return "New"
        case .best: return "Best"
        case .ask: return "Ask"
        case .show: return "Show"
        case .jobs: return "Jobs"
        }
    }

    var endpoint: String {
        switch self {
        case .top: return "topstories"
        case .new: return "newstories"
        case .best: return "beststories"
        case .ask: return "askstories"
        case .show: return "showstories"
        case .jobs: return "jobstories"
        }
    }
}

