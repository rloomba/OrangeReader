import Foundation

actor HNAPIClient {
    static let shared = HNAPIClient()

    private let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchIDs(for feed: FeedType, cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad) async throws -> [Int] {
        let url = baseURL.appendingPathComponent("\(feed.endpoint).json")
        let (data, _) = try await session.data(for: URLRequest(url: url, cachePolicy: cachePolicy))
        let ids = try JSONDecoder().decode([Int].self, from: data)
        return ids
    }

    func fetchItem(id: Int, cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad) async throws -> HNItem {
        let url = baseURL.appendingPathComponent("item/\(id).json")
        let (data, _) = try await session.data(for: URLRequest(url: url, cachePolicy: cachePolicy))
        return try decoder.decode(HNItem.self, from: data)
    }

    func fetchItems(ids: [Int], concurrent maxConcurrent: Int = 8, cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad) async -> [HNItem] {
        guard !ids.isEmpty else { return [] }
        let semaphore = AsyncSemaphore(value: maxConcurrent)
        var results = Array<HNItem?>(repeating: nil, count: ids.count)

        await withTaskGroup(of: (Int, HNItem?).self) { group in
            for (index, id) in ids.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return (index, nil) }
                    await semaphore.wait()
                    do {
                        let item = try await self.fetchItem(id: id, cachePolicy: cachePolicy)
                        await semaphore.signal()
                        return (index, item)
                    } catch {
                        await semaphore.signal()
                        return (index, nil)
                    }
                }
            }

            for await (index, item) in group {
                results[index] = item
            }
        }

        return results.compactMap { $0 }
    }
}

// Simple async semaphore for concurrency limiting
actor AsyncSemaphore {
    private let value: Int
    private var available: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(value: Int) {
        self.value = value
        self.available = value
    }

    func wait() async {
        if available > 0 {
            available -= 1
            return
        }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waiters.append(continuation)
        }
    }

    func signal() {
        if let first = waiters.first {
            waiters.removeFirst()
            first.resume()
        } else {
            available = min(available + 1, value)
        }
    }
}
