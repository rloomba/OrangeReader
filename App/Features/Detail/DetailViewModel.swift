import Foundation

@MainActor
final class DetailViewModel: ObservableObject {
    @Published private(set) var item: HNItem?
    @Published private(set) var commentTree: [CommentTreeNode] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: String?

    let itemID: Int

    init(itemID: Int) {
        self.itemID = itemID
    }

    func load() {
        Task { await loadItemAndComments() }
    }

    private func loadItemAndComments() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let root = try await HNAPIClient.shared.fetchItem(id: itemID)
            self.item = root
            let kids = root.kids ?? []
            let map = await fetchAllCommentItems(ids: kids)
            let tree = buildTree(ids: kids, from: map)
            self.commentTree = tree
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func fetchAllCommentItems(ids: [Int]) async -> [Int: HNItem] {
        var result: [Int: HNItem] = [:]
        var visited = Set<Int>()
        var queue = ids
        visited.formUnion(ids)

        while !queue.isEmpty {
            let count = min(queue.count, 30)
            let batch = Array(queue.prefix(count))
            queue.removeFirst(count)
            let items = await HNAPIClient.shared.fetchItems(ids: batch)
            for item in items {
                result[item.id] = item
                if let kids = item.kids {
                    for k in kids where !visited.contains(k) {
                        visited.insert(k)
                        queue.append(k)
                    }
                }
            }
        }
        return result
    }

    private func buildTree(ids: [Int], from map: [Int: HNItem]) -> [CommentTreeNode] {
        var nodes: [CommentTreeNode] = []
        for id in ids {
            guard let item = map[id], item.deleted != true else { continue }
            var node = CommentTreeNode(id: id, item: item, children: [], isCollapsed: false)
            if let kids = item.kids, !kids.isEmpty {
                node.children = buildTree(ids: kids, from: map)
            }
            nodes.append(node)
        }
        return nodes
    }

    func toggleCollapse(id: Int) {
        _ = toggleCollapseInplace(&commentTree, id: id)
    }

    private func toggleCollapseInplace(_ nodes: inout [CommentTreeNode], id: Int) -> Bool {
        for i in nodes.indices {
            if nodes[i].id == id {
                nodes[i].isCollapsed.toggle()
                return true
            }
            if toggleCollapseInplace(&nodes[i].children, id: id) { return true }
        }
        return false
    }

    func expandAll() {
        setCollapse(&commentTree, collapsed: false)
    }

    func collapseAll() {
        // Collapse only top-level threads
        for i in commentTree.indices { commentTree[i].isCollapsed = true }
    }

    private func setCollapse(_ nodes: inout [CommentTreeNode], collapsed: Bool) {
        for i in nodes.indices {
            nodes[i].isCollapsed = collapsed
            if !nodes[i].children.isEmpty {
                setCollapse(&nodes[i].children, collapsed: collapsed)
            }
        }
    }
}

struct CommentTreeNode: Identifiable, Hashable {
    let id: Int
    let item: HNItem
    var children: [CommentTreeNode]
    var isCollapsed: Bool
}
