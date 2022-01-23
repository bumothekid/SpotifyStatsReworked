//
//  AuthController.swift
//  SpotifyStatsReworked
//
//  Created by David Riegel on 18.01.22.
//

import UIKit
import WebKit

class AuthController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        
        return webView
    }()
    
    public var completionHandler: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    // MARK: -- Functions
    
    func loadWebView() {
        guard let url = AuthManager.shared.signInURL else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code"})?.value else {
            return
        }
        
        webView.isHidden = true
        
        AuthManager.shared.exchangeCodeForToken(code: code, completion: { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandler?(success)
            }
        })
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "Sign In"
        
        view.addSubview(webView)
        webView.frame = view.bounds
        webView.navigationDelegate = self
        
        loadWebView()
    }
}
