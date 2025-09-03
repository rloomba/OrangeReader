import SwiftUI

struct DetailView: View {
    @StateObject private var model: DetailViewModel
    @EnvironmentObject private var settings: AppSettings

    init(itemID: Int) {
        _model = StateObject(wrappedValue: DetailViewModel(itemID: itemID))
    }

    @State private var openURL: URL?
    @State private var readerArticle: ReaderArticle?
    @State private var isReaderLoading = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if let item = model.item {
                    headerView(item: item)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    if isAsk(item: item), let text = item.text {
                        Text(HTMLRenderer.attributedString(from: text))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                    }

                    ForEach(model.commentTree) { node in
                        CommentTreeView(node: node, depth: 0) { id in
                            model.toggleCollapse(id: id)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbar }
        .refreshable { model.load() }
        .onAppear { model.load() }
        .environment(\.openURL, OpenURLAction { url in
            openURL = url
            return .handled
        })
        .sheet(item: $openURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .sheet(item: $readerArticle) { article in
            ReaderScreen(article: article)
                .environmentObject(settings)
        }
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu {
                Button("Expand All") { model.expandAll() }
                Button("Collapse All") { model.collapseAll() }
            } label: {
                Image(systemName: "ellipsis.circle")
            }

            if let urlStr = model.item?.url, let url = URL(string: urlStr) {
                Button {
                    if settings.preferReader {
                        isReaderLoading = true
                        Task {
                            let article = await ReaderExtractor.shared.extractWithTimeout(from: url, allowImages: settings.readerShowImages, timeout: 8)
                            await MainActor.run {
                                isReaderLoading = false
                                if let article { readerArticle = article } else { openURL = url }
                            }
                        }
                    } else {
                        openURL = url
                    }
                } label: { Image(systemName: "book") }
            }

            if let item = model.item, let url = URL(string: item.url ?? "https://news.ycombinator.com/item?id=\(item.id)") {
                ShareLink(item: url) { Image(systemName: "square.and.arrow.up") }
            }
        }
    }

    private func headerView(item: HNItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title ?? "(no title)")
                .font(.system(size: CGFloat(16) * CGFloat(settings.textScale), weight: .semibold))

            StoryMetaView(
                host: Formatters.host(from: item.url),
                score: item.score,
                comments: item.descendants,
                relativeTime: Formatters.relativeTime(from: item.time),
                font: .system(size: CGFloat(13) * CGFloat(settings.textScale)),
                spacing: 8
            )
        }
        .padding(.vertical, 4)
    }

    private func isAsk(item: HNItem) -> Bool {
        guard let url = item.url else { return item.title?.lowercased().hasPrefix("ask hn") == true }
        return url.contains("news.ycombinator.com/item?")
    }
}

private struct CommentRow: View {
    let item: HNItem
    let depth: Int
    let isCollapsed: Bool
    let onToggle: () -> Void
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Capsule()
                .fill(Color("AccentColor").opacity(0.6))
                .frame(width: 3)
                .opacity(depth == 0 ? 0 : 1)
                .padding(.leading, CGFloat(depth) * 8)

            VStack(alignment: .leading, spacing: 6) {
                header
                bodyText
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .padding(.vertical, 6)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(item.by ?? "[unknown]")
                .font(.system(size: CGFloat(12) * CGFloat(settings.textScale), weight: .semibold))
            if let rel = Formatters.relativeTime(from: item.time) {
                Text(rel)
                    .font(.system(size: CGFloat(12) * CGFloat(settings.textScale)))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                .font(.system(size: CGFloat(12) * CGFloat(settings.textScale)))
                .foregroundStyle(.secondary)
        }
    }

    private var bodyText: some View {
        Group {
            if item.deleted == true || item.dead == true {
                Text("[deleted]").italic().foregroundStyle(.secondary)
            } else if let text = item.text {
                Text(HTMLRenderer.attributedString(from: text))
                    .foregroundStyle(.primary)
            } else {
                Text("")
            }
        }
        .font(.system(size: CGFloat(13) * CGFloat(settings.textScale)))
    }
}

private struct CommentTreeView: View {
    let node: CommentTreeNode
    let depth: Int
    let onToggle: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CommentRow(item: node.item, depth: depth, isCollapsed: node.isCollapsed) {
                onToggle(node.id)
            }
            if !node.isCollapsed {
                ForEach(node.children) { child in
                    CommentTreeView(node: child, depth: depth + 1, onToggle: onToggle)
                }
            }
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetailView(itemID: 1)
        }
    }
}
