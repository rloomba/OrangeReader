import Foundation

enum Formatters {
    static func host(from urlString: String?) -> String? {
        guard let urlString, let url = URL(string: urlString), let host = url.host else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    static func relativeTime(from unixTime: TimeInterval?) -> String? {
        guard let unixTime else { return nil }
        let date = Date(timeIntervalSince1970: unixTime)
        let now = Date()
        let diff = now.timeIntervalSince(date)

        if diff < 60 { return "just now" }
        let minute = 60.0
        let hour = 3600.0
        let day = 86400.0
        let week = 604800.0

        if diff < hour { return "\(Int(diff / minute))m" }
        if diff < day { return "\(Int(diff / hour))h" }
        if diff < week { return "\(Int(diff / day))d" }

        // Absolute for long ages
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

