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
    private var micButton = MicButton()

    private var speechDisplayTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor(red: 86/255.0, green: 88/255.0, blue: 103/255.0, alpha: 1.0)
        textView.isEditable = false
        textView.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        return textView
    }()

    private let speechHelper = SpeechHelper()
    private var webView: WKWebView?
    private let config: YMConfig
    private let progressView = UIProgressView(progressViewStyle: .default)

    init(config: YMConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        speechHelper.delegate = self
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(config:) instead")
    }
    
    public override func viewDidLoad() {
        addWebView()
        if config.showCloseButton {
            addCloseButton(tintColor: config.closeButtonColor)
        }
        if config.enableSpeech {
            addMicButton(tintColor: config.micButtonColor)
        }
        addProgressBar()
        log("Loading URL: \(config.url)")
        webView?.load(URLRequest(url: config.url))
    }

    private func addWebView() {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let js = "function sendEventFromiOS(s){document.getElementById('ymIframe').contentWindow.postMessage(JSON.stringify({ event_code: 'send-voice-text', data: s }), '*');}"
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)

        let ymHandler = "ymHandler"
        contentController.add(self, name: ymHandler) //TODO: What does this do?
        configuration.userContentController = contentController
        self.webView = WKWebView(frame: .zero, configuration: configuration)

        webView!.navigationDelegate = self
        view.addSubview(webView!)
        webView!.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        webView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView!.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        webView!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView!.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func addProgressBar() {
        assert(webView != nil, "Progress bar must be added after Webview is initialised")
        webView?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func addCloseButton(tintColor: UIColor) {
        let button = UIButton()
        button.setImage(Image.close.uiImage, for: .normal)
        button.tintColor = tintColor
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        button.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        button.addTarget(self, action: #selector(dismisViewController), for: .touchUpInside)
    }
    
    private func addMicButton(tintColor: UIColor) {
        view.addSubview(micButton)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        micButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
    }

    @objc func micTapped() {
        speechHelper.micButtonTapped()
    }
    
    private func showSpeechDisplayTextView() {
        self.view.insertSubview(speechDisplayTextView, belowSubview: micButton)
        speechDisplayTextView.translatesAutoresizingMaskIntoConstraints = false
        speechDisplayTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        speechDisplayTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speechDisplayTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        speechDisplayTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    @objc func dismisViewController() {
        log(#function)
        self.dismiss(animated: true, completion: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = config.statusBarColor
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return UIStatusBarStyle.lightContent
        } else {
            return UIStatusBarStyle.default
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress", let webView = webView {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1.0 {
                progressView.removeFromSuperview()
            }
        }
    }

    func sendMessageInWebView(text: String) {
        log(#function, text)
        webView?.evaluateJavaScript("sendEventFromiOS('\(text)');", completionHandler: nil)
    }
}

extension YMChatViewController: SpeechDelegate {
    func micButtonTappedWithAuthorizationRestricted() {
        let alert = UIAlertController(title: "Restricted", message: "Your phone has restricted your app from performing speech recognition.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func micButtonTappedWithAuthorizationDenied() {
        let alert = UIAlertController(title: "", message: "To enable Speech Recognization enable it from the Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func newText(_ text: String) {
        log(#function, text)
        speechDisplayTextView.text = text
    }

    func listeningStarted() {
        log(#function)
        micButton.isListening = true
        showSpeechDisplayTextView()
        speechDisplayTextView.text = ""
    }

    func listeningCompleted() {
        log(#function)
        micButton.isListening = false
        speechDisplayTextView.removeFromSuperview()
        if !speechDisplayTextView.text.isEmpty {
            sendMessageInWebView(text: speechDisplayTextView.text)
        }
    }
}

extension YMChatViewController: WKNavigationDelegate, WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

    }

    //TODO: Handle this
}
