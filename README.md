# Orange Reader

Minimal, fast Hacker News for iPhone (iOS 17+). SwiftUI + XcodeGen. Clean reading, full comments, and a pragmatic Reader view with in‑app Safari fallback.

## Quick Start

```
brew install xcodegen
xcodegen generate
open OrangeReader.xcodeproj
```

Run on an iPhone simulator or device.

## Highlights

- Feeds: Top/New/Best/Ask/Show/Jobs with quick title menu
- Detail: nested comments with collapse/expand and bulk controls
- Reader: on‑device extraction (swift‑readability), in‑app Safari links + fallback
- Ergonomics: bottom Reader actions (Open/Share), side configurable
- Settings: live text size, prefer Reader, show images, control position

## Docs

- Architecture: see ARCHITECTURE.md
- Troubleshooting: see TROUBLESHOOTING.md

## Common Commands

- Generate project: `xcodegen generate`
- Clean build: Shift+Cmd+K

## Bundle ID

Currently `com.ryanloomba.minimalhackernews` (keeps signing stable). To change, edit `project.yml` and regenerate.

## Credits

- Hacker News API: https://github.com/HackerNews/API
- Readability: https://github.com/Ryu0118/swift-readability
