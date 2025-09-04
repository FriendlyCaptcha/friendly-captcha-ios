/*!
 * Copyright (c) Friendly Captcha GmbH 2024.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import UIKit
@preconcurrency import WebKit
import Foundation

let VERSION = "1.0.2"

/// A class for interacting with the Friendly Captcha widget.
///
/// This class is the main entry point for the Friendly Captcha SDK. Each instance provides and manages a UIViewController containing a
/// WKWebView that renders the Friendly Captcha widget.
@objc
public class FriendlyCaptcha: NSObject {
    private let sitekey: String
    private let apiEndpoint: String
    private let language: String?
    private let theme: WidgetTheme

    private let viewController: WidgetViewController = WidgetViewController()

    private var widgetState: WidgetState = .initial
    private var response: String = ""
    private var id: String = ""

    /// Initialize an instance of the FriendlyCaptcha class.
    ///
    /// - Parameters:
    ///  - sitekey: The sitekey to use for the widget. This value always starts with `FC`.
    ///  - apiEndpoint: The API endpoint to use for the widget. Valid arguments are `"global"`, `"eu"`, or a URL. Defaults to `"global"`.
    ///  - language: The language to use for the widget. Defaults to the device language. Accepts values like `en` or `en-US`.
    ///  - theme: The theme to use for the widget. This can be `.light`, `.dark`, or `.auto` (which makes the browser or device decide). If `nil`, defaults to `.auto`.
    @objc
    public init(
        sitekey: String,
        apiEndpoint: String = "global",
        language: String? = nil,
        theme: WidgetTheme = .auto
    ) {
        self.sitekey = sitekey
        self.apiEndpoint = apiEndpoint
        self.language = language
        self.theme = theme

        super.init()
        setupViewController()
    }

    // Objective-C doesn't have default parameter values, so this convenience function is provided
    // to allow initializing with only a sitekey. The rest of the parameters will use the defaults.
    // In other cases, callers will need to supply all 4 parameters.
    @objc
    public convenience init(sitekey: String) {
        self.init(sitekey: sitekey, apiEndpoint: "global", language: nil, theme: .auto)
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
  <script>\(JS_SDK)</script>
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
            theme: "\(getTheme())",
            language: "\(getLanguage())"
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

    // Attempts to resolve a theme based on the supplied parameter and
    // the current device settings, if available. Defaults to "auto".
    private func getTheme() -> String {
        if theme == .light {
            return "light"
        } else if theme == .dark {
            return "dark"
        } else {
            if #available(iOS 12.0, *) {
                switch viewController.traitCollection.userInterfaceStyle {
                case .dark:
                    return "dark"
                case .light:
                    return "light"
                default:
                    return "auto"
                }
            }
            return "auto"
        }
    }

    // Attempts to resolve a language based on the supplied parameter,
    // falling back to the device language or "en" as a final resort.
    private func getLanguage() -> String {
        if language != nil {
            return language!
        }

        return Locale.preferredLanguages.first ?? "en"
    }

    /// Set a callback function to be invoked when the widget completes.
    ///
    /// When this happens, you should enable the submit button or unblock the action you are protecting and include the
    /// `response` string in your back-end verification request.
    ///
    /// - Parameter handler: The callback function to be invoked when the widget completes.
    @objc
    public func onComplete(_ handler: @escaping (WidgetCompleteEvent) -> Void) {
        viewController.handleComplete = handler
    }

    /// Set a callback function to be invoked when the widget errors.
    ///
    /// The user will be able to click the widget to try again. This might happen if their internet connection was temporarily down.
    /// It's good practice to **enable** the submit button or **unblock** the action you are protecting when this happens.
    ///
    /// - Parameter handler: The callback function to be invoked when the widget errors.
    @objc
    public func onError(_ handler: @escaping (WidgetErrorEvent) -> Void) {
        viewController.handleError = handler
    }

    /// Set a callback function to be invoked when the widget expires.
    ///
    /// The user will be able to click the widget to try again. This might happen if the user waits
    /// a very long time before submitting after completing the captcha challenge. It's good practice
    /// to **disable** the submit button or **block** the action you are protecting when this happens.
    ///
    /// - Parameter handler: The callback function to be invoked when the widget expires.
    @objc
    public func onExpire(_ handler: @escaping (WidgetExpireEvent) -> Void) {
        viewController.handleExpire = handler
    }

    /// Set a callback function to be invoked when the widget's state changes.
    ///
    /// This callback will be invoked in response to any state change (including—but not limited to—completion, error, and expiration).
    ///
    /// - Parameter handler: The callback function to be invoked when the widget's state changes.
    @objc
    public func onStateChange(_ handler: @escaping (WidgetStateChangeEvent) -> Void) {
        viewController.handleStateChange = { (message) in
            self.widgetState = message.state
            self.response = message.response
            handler(message)
        }
    }

    /// Get the current state of the widget.
    ///
    /// See the [Lifecycle](https://developer.friendlycaptcha.com/docs/v2/sdk/lifecycle) documentation for more information.
    ///
    /// - Returns: The current state of the widget.
    @objc
    public func getState() -> WidgetState {
        widgetState
    }

    /// Get the current widget response.
    ///
    /// This is the value you should send to your back-end to verify the captcha.
    ///
    /// - Returns: The current widget response.
    @objc
    public func getResponse() -> String {
        response
    }

    /// Get the ViewController used for rendering the widget.
    ///
    /// This ViewController contains a WKWebView that renders the Friendly Captcha widget.
    /// You should add this ViewController to your view hierarchy.
    ///
    /// - Returns: A reference to the ViewController that renders the widget.
    @objc
    public func Widget() -> UIViewController {
        viewController
    }

    /// Trigger the widget to start solving a challenge.
    ///
    /// The solving will take place in the background. The behavior of the widget depends on the mode of the Friendly Captcha application.
    ///
    /// * In `interactive` mode, the user will need to click the widget to complete the process.
    /// * In `noninteractive` mode, the widget will complete the process
    @objc
    public func start() {
        viewController.start()
    }

    /// Reset the widget, removing any progress.
    ///
    /// After resetting, the widget can be used again for another challenge.
    @objc
    public func reset() {
        viewController.reset()
    }

    /// Destroy the widget, removing it from the view hierarchy.
    ///
    /// After calling this method, the widget handle is no longer usable.
    @objc
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


// The UIViewController that renders the Friendly Captcha widget.
// Not intended to be used directly, but rather managed via the FriendlyCaptcha object.
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
        if #available(iOS 9.0, *) {
            config.applicationNameForUserAgent = "friendly-captcha-ios/\(VERSION) sdk/\(JS_SDK_VERSION)"
        } else {
            let userAgentScript = "navigator.userAgent = navigator.userAgent + ' friendly-captcha-ios/\(VERSION) sdk/\(JS_SDK_VERSION)';"
            let userAgentScriptObject = WKUserScript(source: userAgentScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            config.userContentController.addUserScript(userAgentScriptObject)
        }

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

    deinit {
        destroy()
    }

    // Handles communication via JavaScript from within the WKWebView.
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

    // Handle links clicked within the WebView. Ensures that the links open in the default browser app, rather than the WebView.
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
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }

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

        // Remove any installed user scripts
        webView.configuration.userContentController.removeAllUserScripts()

        // Stop any loading and clear the WebView
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.removeFromSuperview()
        webView = nil
        view = nil
    }
}
