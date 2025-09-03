# AI Context

A quick reference for AI assistants working on Orange Reader.

## App Summary
- Minimal Hacker News reader (iPhone, iOS 17+).
- SwiftUI app, XcodeGen project. Reader mode via `swift-readability` with in‑app Safari fallback.

## Primary Files
- `project.yml`: XcodeGen config (targets, settings, SPM deps).
- `App/App.swift`: entry point.
- `App/Features/Feed/*`: feed UI + pagination (`FeedViewModel`).
- `App/Features/Detail/*`: detail header + comment tree (`DetailViewModel`).
- `App/Reader/*`: `ReaderExtractor` (main‑actor), `ReaderScreen` (bottom controls), `ReaderWebView`.
- `App/Networking/*`: `HNAPIClient` (cachePolicy-aware), `HTMLRenderer` (strips HTML colors).
- `App/Settings/AppSettings.swift`: persisted settings (text scale, reader prefs).

## Conventions
- Prefer async/await. UI updates on main actor.
- Use `xcodegen generate` after adding/moving files.
- Keep styles minimal; avoid heavy CSS. Ensure dark-mode safe text.
- Don’t conditionally omit `List` rows; filter the data or use `ScrollView`.

## Common Tasks
- Generate + open project:
  - `xcodegen generate`
  - `open OrangeReader.xcodeproj`
- Add a new Swift file:
  - Create under `App/...` then `xcodegen generate`.
- Add SPM dependency:
  - Update `packages:` and `targets:dependencies:` in `project.yml`, then regenerate.

## Reader Mode Notes
- Extraction uses `Readability().parse(url:)` on main actor.
- 8s timeout → fallback to in‑app Safari (never spin forever).
- Cache key includes image preference (`img_on|img_off`).
- Links inside Reader open in in‑app Safari; bottom bar offers Open/Share.

## Pitfalls
- Launch screen: ensure `UILaunchScreen` in Info.plist to avoid letterboxing.
- Testing new files: regenerate project or Xcode won’t see them.
- Dark mode HTML: use `HTMLRenderer.attributedString` (it strips fixed colors) and set `.foregroundStyle(.primary)` where appropriate.

## Roadmap Hooks
- Add Clear Reader Cache in Settings (delete `Caches/ReaderCache/*`).
- Persist per‑feed scroll offsets.
- Optional serif font or images toggle in Reader bar.

## Do / Don’t
- Do keep features minimal and performance-focused.
- Do use `URLRequest.cachePolicy` to control refresh behavior.
- Don’t add heavy dependencies without discussing.
- Don’t use blocking network calls on main threads.
