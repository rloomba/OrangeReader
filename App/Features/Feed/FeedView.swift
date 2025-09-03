import SwiftUI

struct FeedView: View {
    @StateObject private var model = FeedViewModel()
    @State private var selectedItem: HNItem?
    @EnvironmentObject private var settings: AppSettings
    @State private var showSettings = false
    @State private var openURL: URL?
    @State private var readerArticle: ReaderArticle?
    @State private var isReaderLoading = false

    var body: some View {
        NavigationStack {
            List(model.items) { item in
                FeedRow(item: item, onOpenLink: { url in
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
                })
                .onAppear { model.loadMoreIfNeeded(current: item) }
            }
            .listStyle(.plain)
            .listRowSpacing(4)
            .contentMargins(.top, 6, for: .scrollContent)
            .navigationDestination(for: HNItem.self) { item in
                DetailView(itemID: item.id)
            }
            .navigationTitle(model.feed.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { feedToolbar }
            .toolbarTitleMenu {
                ForEach(FeedType.allCases, id: \.self) { feed in
                    Button(action: { model.feed = feed }) {
                        if model.feed == feed { Label(feed.displayName, systemImage: "checkmark") }
                        else { Text(feed.displayName) }
                    }
                }
            }
            .refreshable { await model.refresh() }
            .overlay(alignment: .center) {
                if model.items.isEmpty && model.isLoading { ProgressView().controlSize(.large) }
                if isReaderLoading { ProgressView().controlSize(.large) }
            }
        }
        .onAppear { model.onAppear() }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .sheet(item: $openURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .sheet(item: $readerArticle) { article in
            ReaderScreen(article: article)
                .environmentObject(settings)
        }
    }

    @ToolbarContentBuilder
    private var feedToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
            }
        }
    }
}

private struct FeedRow: View {
    let item: HNItem
    @EnvironmentObject private var settings: AppSettings
    var onOpenLink: (URL) -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                let urlString = item.url ?? "https://news.ycombinator.com/item?id=\(item.id)"
                if let url = URL(string: urlString) { onOpenLink(url) }
            } label: {
                FaviconView(host: Formatters.host(from: item.url), size: 20)
            }
            .buttonStyle(.plain)

            NavigationLink(value: item) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title ?? "(no title)")
                        .font(.system(size: CGFloat(16) * CGFloat(settings.textScale), weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(4)

                    StoryMetaView(
                        host: Formatters.host(from: item.url),
                        score: item.score,
                        comments: item.descendants,
                        relativeTime: Formatters.relativeTime(from: item.time),
                        font: .system(size: CGFloat(13) * CGFloat(settings.textScale)),
                        spacing: 6
                    )
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
