import SwiftUI

struct FaviconView: View {
    let host: String?
    var size: CGFloat = 20

    private var iconURL: URL? {
        guard let host, !host.isEmpty else { return nil }
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = host
        comps.path = "/favicon.ico"
        return comps.url
    }

    var body: some View {
        Group {
            if let url = iconURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
            Image(systemName: "globe")
                .font(.system(size: size * 0.55))
                .foregroundStyle(.secondary)
        }
    }
}
