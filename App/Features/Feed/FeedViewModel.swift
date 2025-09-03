import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var items: [HNItem] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?
    @Published var feed: FeedType = .top {
        didSet { resetAndLoad() }
    }

    private var ids: [Int] = []
    private var nextIndex: Int = 0
    private let pageSize: Int = 30
    private var cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad

    func onAppear() {
        if items.isEmpty { resetAndLoad() }
    }

    func resetAndLoad() {
        items = []
        ids = []
        nextIndex = 0
        cachePolicy = .returnCacheDataElseLoad
        Task { await loadInitial() }
    }

    func loadInitial() async {
        isLoading = true
        defer { isLoading = false }
        do {
            ids = try await HNAPIClient.shared.fetchIDs(for: feed, cachePolicy: cachePolicy)
            nextIndex = 0
            try await loadMore()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func loadMoreIfNeeded(current item: HNItem?) {
        guard let item else { return }
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5, limitedBy: items.startIndex) ?? items.startIndex
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            Task { try? await loadMore() }
        }
    }

    func refresh() async {
        // Force network fetch ignoring cache
        items = []
        ids = []
        nextIndex = 0
        cachePolicy = .reloadIgnoringLocalCacheData
        await loadInitial()
    }

    private func loadMore() async throws {
        guard nextIndex < ids.count else { return }
        isLoading = true
        defer { isLoading = false }

        let end = min(nextIndex + pageSize, ids.count)
        let batch = Array(ids[nextIndex..<end])
        nextIndex = end
        let fetched = await HNAPIClient.shared.fetchItems(ids: batch, cachePolicy: cachePolicy)
        items.append(contentsOf: fetched)
    }
}
