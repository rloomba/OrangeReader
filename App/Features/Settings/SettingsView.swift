import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        NavigationStack {
            Form {
                Section("Text Size") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "textformat.size.smaller")
                            Slider(value: $settings.textScale, in: 0.75...1.4, step: 0.01)
                            Image(systemName: "textformat.size.larger")
                        }
                        .tint(Color("AccentColor"))

                        // Live preview
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Preview title wraps to multiple lines as needed")
                                .font(.system(size: CGFloat(17) * CGFloat(settings.textScale), weight: .semibold))
                            StoryMetaView(
                                host: "example.com",
                                score: 123,
                                comments: 45,
                                relativeTime: "5h",
                                font: .system(size: CGFloat(13) * CGFloat(settings.textScale)),
                                spacing: 8
                            )
                        }
                        .padding(.top, 4)

                        HStack {
                            Spacer()
                            Button("Reset") { settings.textScale = 1.0 }
                                .buttonStyle(.bordered)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("Reader") {
                    Toggle(isOn: $settings.preferReader) {
                        Text("Prefer Reader when available")
                    }
                    Picker("Controls position", selection: $settings.readerControlsRight) {
                        Label("Left", systemImage: "arrow.left").tag(false)
                        Label("Right", systemImage: "arrow.right").tag(true)
                    }
                    .pickerStyle(.segmented)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Preview")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            if settings.readerControlsRight { Spacer() }
                            HStack(spacing: 16) {
                                Image(systemName: "safari")
                                Image(systemName: "square.and.arrow.up")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            if !settings.readerControlsRight { Spacer() }
                        }
                    }
                    Toggle(isOn: $settings.readerShowImages) {
                        Text("Show images in Reader")
                    }
                }
                Section("Storage") {
                    ClearReaderCacheButton()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppSettings())
    }
}

private struct ClearReaderCacheButton: View {
    @State private var isClearing = false
    @State private var done = false

    var body: some View {
        HStack {
            Button {
                isClearing = true
                Task { await ReaderCache.shared.clear(); await MainActor.run { isClearing = false; done = true } }
            } label: {
                if isClearing { ProgressView().controlSize(.small) }
                Text("Clear Reader Cache")
            }
            Spacer()
            if done { Image(systemName: "checkmark.circle.fill").foregroundStyle(.secondary) }
        }
    }
}
