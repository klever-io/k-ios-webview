//struct KWebview {
//    var text = "Hello, World!"
//}

import SwiftUI
import WebKit
import Combine

public class KWebviewViewModel: ObservableObject {
    public var webViewNavigationPublisher = PassthroughSubject<KWebViewNavigation, Never>()
    public var webviewStatus = PassthroughSubject<KWebViewStatus, Never>()

    public init() {}

    public func openURL(_ url: String) {
        self.webViewNavigationPublisher.send(.go(url: url))
    }

    public func goBack() {
        self.webViewNavigationPublisher.send(.backward)
    }

    public func goForward() {
        self.webViewNavigationPublisher.send(.forward)
    }
}

// For identifiying WebView's forward and backward navigation
public enum KWebViewNavigation {
    case backward, forward, reload, go(url: String)
}

public struct KWebViewStatus {
    public var canGoback: Bool = false

    public var title: String = ""

    public var canGoForward: Bool = false

    public init(canGoback: Bool, title: String, canGoForward: Bool) {
        self.canGoback = canGoback
        self.title = title
        self.canGoForward = canGoForward
    }
}


#if os(iOS)

public struct KWebview: UIViewRepresentable {
    // Viewmodel object
    @ObservedObject var viewModel: KWebviewViewModel

    public init(_ viewModel: KWebviewViewModel) {
        self.viewModel = viewModel
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true

        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView

        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
    }


    public class Coordinator : NSObject, WKNavigationDelegate {
        var parent: KWebview

        var webViewNavigationSubscriber: AnyCancellable? = nil

        var webView: WKWebView? = nil

        init(_ uiWebView: KWebview) {
            self.parent = uiWebView

            super.init()

            self.webViewNavigationSubscriber = self.parent.viewModel.webViewNavigationPublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: self.handlerEvents)
        }

        deinit {
            webViewNavigationSubscriber?.cancel()
        }

        private func handlerEvents(navigation: KWebViewNavigation) {
            print("Chengao aqui \(navigation)")
            guard let webView = self.webView else { return }

            switch navigation {
            case .backward:
                if webView.canGoBack {
                    webView.goBack()
                }
            case .forward:
                if webView.canGoForward {
                    webView.goForward()
                }
            case .reload:
                webView.reload()

            case .go(let url):
                if let url = URL(string: url) {
                    webView.load(URLRequest(url: url))
                }
            }
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.viewModel.webviewStatus.send(
                .init(canGoback: webView.canGoBack, title: webView.title ?? "", canGoForward: webView.canGoForward)
            )
        }

        public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        }

        public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.parent.viewModel.webviewStatus.send(
                .init(canGoback: webView.canGoBack, title: webView.title ?? "", canGoForward: webView.canGoForward)
            )
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            decisionHandler(.allow)
        }
    }
}

#endif

