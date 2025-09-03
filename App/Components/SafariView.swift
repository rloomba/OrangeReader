import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var entersReaderIfAvailable: Bool = true

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable
        let vc = SFSafariViewController(url: url, configuration: config)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

