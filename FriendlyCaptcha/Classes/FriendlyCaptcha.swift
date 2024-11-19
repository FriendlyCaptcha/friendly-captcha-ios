import UIKit
import WebKit

public class FriendlyCaptcha {
    private let sitekey: String
    private let apiEndpoint: String
    private let language: String?
    private let theme: WidgetTheme

    private let viewController: WidgetViewController = WidgetViewController()

    private var widgetState: WidgetState = .initial
    private var response: String = ""

    public init(
        sitekey: String,
        apiEndpoint: String = "global",
        language: String? = nil,
        theme: WidgetTheme = .light
    ) {
        self.sitekey = sitekey
        self.apiEndpoint = apiEndpoint
        self.language = language
        self.theme = theme

        setupViewController()
    }

    private func setupViewController() {
        viewController.handleStateChange = { message in
            self.widgetState = message.state
            self.response = message.response
        }
        viewController.htmlContent = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0">
  <div id="widget" style="width: 100%"></div>
  <script src="https://cdn.jsdelivr.net/npm/@friendlycaptcha/sdk@0.1.8/site.compat.min.js"></script>
  <script>
    function send(type, data) {
        window.webkit.messageHandlers.bus.postMessage({type, data});
    }

    window.widget = null;

    function main() {
        var mount = document.getElementById('widget');
        window.widget = frcaptcha.createWidget({
            element: mount,
            sitekey: "\(sitekey)",
            apiEndpoint: "\(apiEndpoint)",
            theme: "\(theme)",
            \(language != nil ? "language: '\(language!)'" : "")
        });

        window.widget.addEventListener('frc:widget.complete', function(event) {
            send('complete', event.detail);
        });

        window.widget.addEventListener('frc:widget.error', function(event) {
            send('error', event.detail);
        });

        window.widget.addEventListener('frc:widget.expire', function(event) {
            send('expire', event.detail);
        });

        widget.addEventListener('frc:widget.statechange', function(event) {
            send('statechange', event.detail);
        });
    }

    if (document.readyState !== 'loading') {
        main();
    } else {
        document.addEventListener('DOMContentLoaded', main);
    }
  </script>
</body>
</html>
"""
    }

    public func onComplete(_ handler: @escaping (WidgetCompleteEvent) -> Void) {
        viewController.handleComplete = handler
    }

    public func onError(_ handler: @escaping (WidgetErrorEvent) -> Void) {
        viewController.handleError = handler
    }

    public func onExpire(_ handler: @escaping (WidgetExpireEvent) -> Void) {
        viewController.handleExpire = handler
    }

    public func onStateChange(_ handler: @escaping (WidgetStateChangeEvent) -> Void) {
        viewController.handleStateChange = { (message) in
            self.widgetState = message.state
            self.response = message.response
            handler(message)
        }
    }

    public func getState() -> WidgetState {
        widgetState
    }

    public func getResponse() -> String {
        response
    }

    public func Widget() -> UIViewController {
        viewController
    }

    public func start() {
        viewController.start()
    }

    public func reset() {
        viewController.reset()
    }

    public func destroy() {
        viewController.destroy()
    }
}

class WidgetViewController: UIViewController, WKScriptMessageHandler {
    var htmlContent: String?

    var handleComplete: (WidgetCompleteEvent) -> Void = { _ in }
    var handleError: (WidgetErrorEvent) -> Void = { _ in }
    var handleExpire: (WidgetExpireEvent) -> Void = { _ in }
    var handleStateChange: (WidgetStateChangeEvent) -> Void = { _ in }

    private var webView: WKWebView!

    override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "bus")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: .zero, configuration: config)
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let htmlContent = htmlContent {
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "bus",
           let body = message.body as? [String: Any],
           let type = body["type"] as? String,
           let jsonData = try? JSONSerialization.data(withJSONObject: body["data"] as Any) {
            switch type {
            case "complete":
                let message = try! JSONDecoder().decode(WidgetCompleteEvent.self, from: jsonData)
                handleComplete(message)
            case "error":
                let message = try! JSONDecoder().decode(WidgetErrorEvent.self, from: jsonData)
                handleError(message)
            case "expire":
                let message = try! JSONDecoder().decode(WidgetExpireEvent.self, from: jsonData)
                handleExpire(message)
            case "statechange":
                let message = try! JSONDecoder().decode(WidgetStateChangeEvent.self, from: jsonData)
                handleStateChange(message)
            default:
                print("Unknown message type", body)
            }
        }
    }

    func start() {
        webView.evaluateJavaScript("window.widget && window.widget.start();", completionHandler: nil)
    }

    func reset() {
        webView.evaluateJavaScript("window.widget && window.widget.reset();", completionHandler: nil)
    }

    func destroy() {
        webView.evaluateJavaScript("window.widget && window.widget.destroy();", completionHandler: nil)
    }
}

public enum WidgetState: String, Codable {
    case initial = "init"
    case reset
    case unactivated
    case activating
    case activated
    case requesting
    case solving
    case verifying
    case completed
    case expired
    case error
    case destroyed
}

public enum WidgetTheme {
    case light
    case dark
    case auto
}

public struct WidgetCompleteEvent: Codable {
    public let state: WidgetState
    public let response: String
    public let id: String
}

public struct WidgetErrorEvent: Codable {
    public let state: WidgetState
    public let response: String
    public let error: WidgetErrorData
    public let id: String
}

public struct WidgetExpireEvent: Codable {
    public let state: WidgetState
    public let response: String
    public let id: String
}

public struct WidgetStateChangeEvent: Codable {
    public let error: WidgetErrorData?
    public let id: String
    public let response: String
    public let state: WidgetState
}

public struct WidgetErrorData: Codable {
    public let code: WidgetErrorCode
    public let detail: String
    public let title: String?
}

public enum WidgetErrorCode: String, Codable {
    case network_error
    case sitekey_invalid
    case sitekey_missing
    case other
}
