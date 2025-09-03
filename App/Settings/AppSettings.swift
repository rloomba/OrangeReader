import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    @Published var textScale: Double {
        didSet {
            UserDefaults.standard.set(textScale, forKey: "textScale")
        }
    }
    @Published var preferReader: Bool {
        didSet {
            UserDefaults.standard.set(preferReader, forKey: "preferReader")
        }
    }
    @Published var readerControlsRight: Bool {
        didSet { UserDefaults.standard.set(readerControlsRight, forKey: "readerControlsRight") }
    }
    @Published var readerShowImages: Bool {
        didSet { UserDefaults.standard.set(readerShowImages, forKey: "readerShowImages") }
    }

    init() {
        let saved = UserDefaults.standard.object(forKey: "textScale") as? Double ?? 1.0
        // Clamp to a reasonable range
        self.textScale = min(max(saved, 0.75), 1.4)
        self.preferReader = (UserDefaults.standard.object(forKey: "preferReader") as? Bool) ?? true
        self.readerControlsRight = (UserDefaults.standard.object(forKey: "readerControlsRight") as? Bool) ?? true
        self.readerShowImages = (UserDefaults.standard.object(forKey: "readerShowImages") as? Bool) ?? false
    }
}
