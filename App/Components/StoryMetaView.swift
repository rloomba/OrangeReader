import SwiftUI

struct StoryMetaView: View {
    let host: String?
    let score: Int?
    let comments: Int?
    let relativeTime: String?
    var font: Font = .footnote
    var spacing: CGFloat = 12

    var body: some View {
        HStack(spacing: spacing) {
            if let host, !host.isEmpty {
                Text(host)
            }
            if let score {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .imageScale(.small)
                    Text("\(score)")
                }
            }
            if let comments {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .imageScale(.small)
                    Text("\(comments)")
                }
            }
            if let relativeTime {
                Text(relativeTime)
            }
        }
        .font(font)
        .foregroundStyle(.secondary)
    }
}
