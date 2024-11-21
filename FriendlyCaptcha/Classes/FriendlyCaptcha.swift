import UIKit
@preconcurrency import WebKit

let VERSION = "1.0.0"
let JS_SDK_VERSION = "0.1.9"

/**
 * The main entry point for the FriendlyCaptcha SDK.
 * Each instance of this class manages a single Friendly Captcha widget.
 *
 * @param sitekey The sitekey to use for the widget. This value always starts with `FC`.
 * @param apiEndpoint The API endpoint to use for the widget. Valid values are `"global"` and `"eu"` or a URL. Defaults to `"global"`.
 * @param language The language to use for the widget. Defaults to the device language. Accepts values like `en` or `en-US`.
 * @param theme The theme to use for the widget. This can be `"light"`, `"dark"` or `"auto" (which makes the browser decide)`.
 */
public class FriendlyCaptcha {
    private let sitekey: String
    private let apiEndpoint: String
    private let language: String?
    private let theme: WidgetTheme

    private let viewController: WidgetViewController = WidgetViewController()

    private var widgetState: WidgetState = .initial
    private var response: String = ""
    private var id: String = ""

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
            self.id = message.id
        }
        viewController.htmlContent = """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0">
  <div id="widget" style="width: 100%; font-size: 16px"></div>
  <script src="https://cdn.jsdelivr.net/npm/@friendlycaptcha/sdk@\(JS_SDK_VERSION)/site.compat.min.js"></script>
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

    /**
     * Set a listener for when the widget completes. When this happens, you should
     * enable the submit button on the action you are protecting and send the `response` to your server
     * for verification.
     */
    public func onComplete(_ handler: @escaping (WidgetCompleteEvent) -> Void) {
        viewController.handleComplete = handler
    }

    /**
     * Set a listener for when the widget encounters an error. The user will be able to click the
     * widget to try again, maybe their internet connection was down temporarily.
     *
     * It's good practice to enable the submit button on the action you are protecting when this happens.
     */
    public func onError(_ handler: @escaping (WidgetErrorEvent) -> Void) {
        viewController.handleError = handler
    }

    /**
     * Set a listener for when the widget expires. The user will be able to click the widget to try again.
     * This happens if the user waits a very long time before submitting after completing the
     * captcha challenge.
     *
     * It's good practice to disable the submit button on the action you are protecting when this happens.
     */
    public func onExpire(_ handler: @escaping (WidgetExpireEvent) -> Void) {
        viewController.handleExpire = handler
    }

    /**
     * Set a listener for when the widget state changes - that means any change happens to the
     * widget. You can use this to keep the `response` value in sync with the widget (that is the
     * value you should send to your server to verify the captcha).
     */
    public func onStateChange(_ handler: @escaping (WidgetStateChangeEvent) -> Void) {
        viewController.handleStateChange = { (message) in
            self.widgetState = message.state
            self.response = message.response
            handler(message)
        }
    }

    /**
     * Returns the current state of the widget.
     * See the [Lifecycle](https://developer.friendlycaptcha.com/docs/v2/sdk/lifecycle) documentation for more information.
     *
     * @see WidgetState
     */
    public func getState() -> WidgetState {
        widgetState
    }

    /**
     * Returns the `frc-captcha-response` value from the widget. This is the value you should send
     * to your server to verify the captcha.
     */
    public func getResponse() -> String {
        response
    }

    /**
     * Returns the UIViewController containing the WKWebView that renders the Friendly Captcha widget.
     * This is the view you should add to your view hierarchy.
     */
    public func Widget() -> UIViewController {
        viewController
    }

    /**
     * Trigger the widget to start a challenge. The widget will start a challenge solving in the background.
     *
     * The behavior of the widget depends on the mode of the Friendly Captcha application (sitekey):
     *
     * * In `interactive` mode, the user will need to click the widget to complete the process.
     * * In `noninteractive` mode, the widget will complete the process automatically.
     */
    public func start() {
        viewController.start()
    }

    /**
     * Reset the widget, removing any progress. This way it can be used again for another challenge.
     */
    public func reset() {
        viewController.reset()
    }

    /**
     * Destroy the widget, hiding it from the view hierarchy.
     *
     * After calling this method, the widget handle is no longer usable.
     */
    public func destroy() {
        widgetState = .destroyed
        response = ".DESTROYED"

        viewController.handleStateChange(WidgetStateChangeEvent(error: nil, id: id, response: response, state: widgetState))

        viewController.handleComplete = { _ in }
        viewController.handleError = { _ in }
        viewController.handleExpire = { _ in }
        viewController.handleStateChange = { _ in }

        viewController.destroy()
    }
}

/**
 * The UIViewController that renders the Friendly Captcha widget.
 * Not intended to be used directly, but rather managed via the FriendlyCaptcha object.
 */
class WidgetViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
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
        config.applicationNameForUserAgent = "friendly-captcha-ios/\(VERSION) sdk/\(JS_SDK_VERSION)"

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let htmlContent = htmlContent {
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }

    /**
     * Handles communication via JavaScript from within the WKWebView.
     */
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

    /**
     * Handle links clicked within the WebView. Ensures that the links open in the default browser app, rather than the WebView.
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // Handle links.
        if navigationAction.navigationType == .linkActivated {

            // Make sure tt ahe URL is set.
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Check for the scheme component.
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if components?.scheme == "http" || components?.scheme == "https" {

                // Open the link in the external browser.
                UIApplication.shared.open(url)

                // Cancel the decisionHandler because we managed the navigationAction.
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }

    func start() {
        webView.evaluateJavaScript("window.widget && window.widget.start();", completionHandler: nil)
    }

    func reset() {
        webView.evaluateJavaScript("window.widget && window.widget.reset();", completionHandler: nil)
    }

    func destroy() {

        // Remove the message handler
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "bus")

        // Stop any loading and clear the WebView
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.removeFromSuperview()
        webView = nil
        view = nil
    }
}
