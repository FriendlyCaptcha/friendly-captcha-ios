//
//  Widget.swift
//  FriendlyCaptcha
//
//  Created by Aaron Greenberg on 11/1/24.
//


import UIKit
import WebKit

public class Widget: UIView {
    private var webView: WKWebView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }
    
    private func setupWebView() {
        webView = WKWebView(frame: self.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.loadHTMLString(htmlContent(), baseURL: nil)
        self.addSubview(webView)
    }
    
    private func htmlContent() -> String {
        return """
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0">
  <div style="width: 100%" class="frc-captcha" data-sitekey="FCMGD7SIQS6JTVKU"></div>
  <script type="module" src="https://cdn.jsdelivr.net/npm/@friendlycaptcha/sdk@0.1.8/site.min.js" async defer></script>
  <script nomodule src="https://cdn.jsdelivr.net/npm/@friendlycaptcha/sdk@0.1.8/site.compat.min.js" async defer></script>
</body>
</html>
"""
    }
}
