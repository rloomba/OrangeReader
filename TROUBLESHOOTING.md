## Troubleshooting

### App shows black bars / not full screen
- Cause: launch screen not recognized → app runs letterboxed.
- Fix: Info.plist needs a modern launch screen entry:
  ```
  <key>UILaunchScreen</key>
  <dict>
    <key>UIImageName</key>
    <string></string>
  </dict>
  ```
- Uninstall the app, clean, and re-run.

### List crash: “Expected dequeued view…”
- Cause: Conditionally omitting `List` rows inside `ForEach`.
- Fix: Use filtered collections in `ForEach` or switch to `ScrollView` + `LazyVStack` (used for comments).

### ExtensionKit logs: “Failed to terminate process… No such process found”
- Cause: WebKit / SafariView lifecycle noise.
- Impact: Harmless. Suppress via scheme env `OS_ACTIVITY_MODE=disable` during development.

### Reader stuck on spinner
- Fixes in place:
  - ReaderExtractor runs on main actor (WebKit requirement).
  - 8s timeout with automatic fallback to in‑app Safari.
- If still stuck: verify connectivity; try a different article.

### Dark text on dark background in comments
- Cause: HTML colors in comment text.
- Fix: `HTMLRenderer` strips foreground/background colors; Views apply `.foregroundStyle(.primary)`.

### Pull‑to‑refresh doesn’t update
- Cause: Cached responses.
- Fix: Refresh sets cache policy to `.reloadIgnoringLocalCacheData` and refetches.

### “Missing AppIcon” build error
- Fix: Provide a 1024×1024 image in `App/Resources/Assets.xcassets/AppIcon.appiconset` or keep the placeholder.

### “Missing bundle ID” / install failure
- Ensure Info.plist is used and bundle ID is set (XcodeGen):
  - `INFOPLIST_FILE = App/Info.plist`
  - `PRODUCT_BUNDLE_IDENTIFIER = com.ryanloomba.minimalhackernews`
  - Regenerate with `xcodegen generate`

### New files not compiling
- Regenerate project after adding files: `xcodegen generate`.
- Clean build folder (Shift+Cmd+K) if needed.

### swift-readability errors
- Ensure SPM resolves the package (network required on first fetch).
- API in use: `Readability().parse(url:)` on main actor.
- We unwrap `title`/`content` and fallback to Safari on parse failure.
