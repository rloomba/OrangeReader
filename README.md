# Orange Reader

Minimal, fast Hacker News for iPhone (iOS 17+). SwiftUI + XcodeGen. Clean reading, full comments, and a pragmatic Reader view with in‑app Safari fallback.

<img width="241.2" height="524.4" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-05 at 22 09 13" src="https://github.com/user-attachments/assets/105fe1d6-0042-4a04-9728-10aecbb16c7f" />
<img width="241.2" height="524.4" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-05 at 22 09 50" src="https://github.com/user-attachments/assets/2d75e7d6-2554-44e3-b696-bddfe346b0e6" />
</br>
<img width="241.2" height="524.4" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-05 at 22 09 29" src="https://github.com/user-attachments/assets/db2a0332-e6f9-45d9-b923-34ec77fd933c" />
<img width="241.2" height="524.4" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-05 at 22 09 39" src="https://github.com/user-attachments/assets/e93daf0a-2331-42da-b63d-7ee2df79a859" />



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
