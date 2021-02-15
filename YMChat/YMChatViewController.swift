//
//  YMChatViewController.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 12/02/21.
//

import Foundation
import UIKit
import WebKit

public class YMChatViewController: UIViewController {
    var webView = WKWebView()
    let config: YMConfig
    let progressView = UIProgressView(progressViewStyle: .default)
    
    init(config: YMConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(config:) instead")
    }
    
    public override func viewDidLoad() {
        addWebView()
        if config.closeButton.visible {
            addCloseButton(tintColor: config.closeButton.tint)
        }
        addProgressBar()
        
        webView.load(URLRequest(url: config.url))
    }
    
    private func addWebView() {
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    func addProgressBar() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func addCloseButton(tintColor: UIColor) {
        let bundle = Bundle(for: YMChatViewController.self)
        let image = UIImage(named: "close", in: bundle, compatibleWith: .none)
        
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        button.addTarget(self, action: #selector(dismisViewController), for: .touchUpInside)
    }
    
    @objc func dismisViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .red
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1.0 {
                progressView.removeFromSuperview()
            }
        }
    }
}

extension YMChatViewController: WKNavigationDelegate {
    
}
