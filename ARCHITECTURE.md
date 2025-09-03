# Architecture

## Goals

- Minimal, fast browsing of Hacker News
- Clean reading experience with optional Reader mode
- Small, understandable codebase; easy to iterate

## Overview

- UI: SwiftUI (iOS 17+), single iPhone target
- Build: XcodeGen (`project.yml`)
- Data: Hacker News Firebase API (IDs → items)
- Models: `HNItem`, `HNUser`, `FeedType`
- Networking: `URLSession`, async/await, light caching
- Reader: `swift-readability` for on‑device extraction

## Project Layout

```
App/
  App.swift                     # Entry point
  Resources/                    # Assets, AppIcon, launch, etc.
  Models/                       # HNItem, HNUser, FeedType
  Networking/                   # HNAPIClient, HTMLRenderer
  Utilities/                    # Formatters
  Components/                   # SafariView, FaviconView, StoryMetaView
  Features/
    Feed/                       # FeedView, FeedViewModel
    Detail/                     # DetailView, DetailViewModel (comment tree)
    Settings/                   # AppSettings, SettingsView
  Reader/
    ReaderExtractor.swift       # Readability wrapper + cache (main‑actor)
    ReaderView.swift            # ReaderWebView + ReaderScreen (bottom bar)
Tests/
  OrangeReaderTests.swift
```

## Data Flow

### Feed
1. Fetch `/{feed}.json` → [ids]
2. Page through ids (page ~30)
3. `fetchItems(ids:, concurrent: 8)`; append to `items`
4. Pull‑to‑refresh forces `.reloadIgnoringLocalCacheData`

### Detail (comments)
1. Fetch root item
2. BFS fetch for all descendant comments, build `CommentTreeNode` tree
3. Render recursively with collapse/expand per subtree; bulk Expand/Collapse All

### Reader
- On main actor, `Readability().parse(url:)` → `{ title, content }`
- Wrap with minimal HTML (neutral colors), conditionally hide images
- Cache to disk by `(url, variant)` where variant = `img_on | img_off`
- 8s timeout → fallback to in‑app Safari
- Link taps inside Reader open in in‑app Safari sheet; Reader remains visible

## Networking & Caching

- HN API fetches use `URLRequest.cachePolicy`:
  - Normal browsing: `.returnCacheDataElseLoad`
  - Pull‑to‑refresh: `.reloadIgnoringLocalCacheData`
- Reader cache: JSON files under Caches/ReaderCache keyed by URL + variant

## UI Notes

- Feed rows: single‑line host + compact meta; favicon opens article directly
- Detail: Ask HN text and comments render HTML via `HTMLRenderer` which strips fixed colors → dark‑mode safe
- Reader bottom actions: open/share; side configurable via settings

## Conventions

- Prefer async/await; update UI from main actor
- Keep Views dumb; put loading logic in ViewModels/actors
- Avoid heavy CSS; use minimal neutralization in Reader only
- Don’t conditionalize `List` rows — use filtered collections or `ScrollView`

## Extending

- Search: integrate Algolia; add a tab or toolbar action
- Offline: Persist items/comments (e.g., SQLite/Core Data) and hydrate on launch
- Theming: add serif option for Reader, alternate color schemes
- CI: add GitHub Actions to run `xcodegen` and `xcodebuild test`
