import SwiftUI

@main
struct OrangeReaderApp: App {
    @StateObject private var settings = AppSettings()
    var body: some Scene {
        WindowGroup {
            FeedView()
                .tint(Color("AccentColor"))
                .environmentObject(settings)
        }
    }
}
