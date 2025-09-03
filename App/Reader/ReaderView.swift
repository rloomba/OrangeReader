import SwiftUI
import WebKit

struct ReaderWebView: UIViewRepresentable {
    let article: ReaderArticle
    let onLink: (URL) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onLink: onLink) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .systemBackground
        web.scrollView.backgroundColor = .systemBackground
        web.navigationDelegate = context.coordinator
        return web
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(article.contentHTML, baseURL: article.url)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onLink: (URL) -> Void
        init(onLink: @escaping (URL) -> Void) { self.onLink = onLink }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                onLink(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

struct ReaderScreen: View {
    let article: ReaderArticle
    @EnvironmentObject private var settings: AppSettings
    @State private var safariURL: URL?

    var body: some View {
        NavigationStack {
            ReaderWebView(article: article) { url in
                safariURL = url
            }
            .navigationTitle(article.url.host ?? "Reader")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) { bottomBar }
        }
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }

    private var bottomBar: some View {
        HStack {
            if settings.readerControlsRight { Spacer() }
            HStack(spacing: 16) {
                Button { safariURL = article.url } label: {
                    Label("Open", systemImage: "safari")
                }
                ShareLink(item: article.url) { Label("Share", systemImage: "square.and.arrow.up") }
            }
            .labelStyle(.iconOnly)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            if !settings.readerControlsRight { Spacer() }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
