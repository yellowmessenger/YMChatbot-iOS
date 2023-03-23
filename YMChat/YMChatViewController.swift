//
//  YMChatViewController.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 12/02/21.
//

import Foundation
import UIKit
import WebKit

protocol YMChatViewControllerDelegate: AnyObject {
    func eventReceivedFromBot(code: String, data: String?)
    func botCloseButtonTapped()
}

@objc(YMChatViewController)
open class YMChatViewController: UIViewController {
    private var micButton: MicButton
    weak var delegate: YMChatViewControllerDelegate?

    private var speechDisplayTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = UIColor(red: 86/255.0, green: 88/255.0, blue: 103/255.0, alpha: 1.0)
        textView.isEditable = false
        textView.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
        return textView
    }()

    private var speechHelper: SpeechHelper?
    private var webView: WKWebView?
    private let config: YMConfig

    init(config: YMConfig) {
        self.config = config
        self.micButton = MicButton(config.micButtonColor)
        super.init(nibName: nil, bundle: nil)
        if config.enableSpeech {
            speechHelper = SpeechHelper()
            speechHelper?.delegate = self
        }
        modalPresentationStyle = .fullScreen
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(config:) instead")
    }

    deinit {
        webView?.stopLoading()
    }
    
    open override func viewDidLoad() {
        addWebView()
        if config.showCloseButton {
            addCloseButton(tintColor: config.closeButtonColor)
        }
        if config.enableSpeech {
            addMicButton()
        }
        log("Loading URL: \(config.url)")
        webView?.load(URLRequest(url: config.url))
    }

    func reloadWebView() {
        webView?.load(URLRequest(url: config.url))
    }

    private func addWebView() {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let js = "function sendEventFromiOS(s){document.getElementById('ymIframe').contentWindow.postMessage(JSON.stringify({ event_code: 'send-voice-text', data: s }), '*');}"
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)

        contentController.add(LeakAvoider(delegate:self), name: "ymHandler")
        configuration.userContentController = contentController
        self.webView = WKWebView(frame: .zero, configuration: configuration)

        webView!.navigationDelegate = self
        webView!.uiDelegate = self
        view.addSubview(webView!)
        webView!.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        webView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView!.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        webView!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView!.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private let closeButton = UIButton()
    private func addCloseButton(tintColor: UIColor) {
        let closeImage = UIImage(named: "close", in: Bundle.assetBundle, compatibleWith: nil) ?? UIImage()
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = tintColor
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        closeButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
        closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        closeButton.addTarget(self, action: #selector(botCloseButtonTapped), for: .touchUpInside)
    }
    
    private func addMicButton() {
        view.addSubview(micButton)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: config.version == 1 ? -70 : -90).isActive = true
        micButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
    }

    @objc func micTapped() {
        speechHelper?.micButtonTapped()
    }
    
    private func showSpeechDisplayTextView() {
        self.view.insertSubview(speechDisplayTextView, belowSubview: micButton)
        speechDisplayTextView.translatesAutoresizingMaskIntoConstraints = false
        speechDisplayTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        speechDisplayTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speechDisplayTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        speechDisplayTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    @objc func botCloseButtonTapped() {
        log(#function)
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.botCloseButtonTapped()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = config.statusBarColor
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        config.statusBarStyle
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

    func handleInternalEvent(code: String) {
        switch code {
        case "image-opened":
            closeButton.isHidden = true
            if config.enableSpeech {
                micButton.isHidden = true
            }
        case "image-closed":
            closeButton.isHidden = false
            if config.enableSpeech {
                micButton.isHidden = false
            }
        case "close-bot":
            delegate?.eventReceivedFromBot(code: "bot-closed", data: nil)
        default: break
        }
    }
}

extension YMChatViewController: WKNavigationDelegate, WKScriptMessageHandler {
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "ymHandler" {
            guard let dict = message.body as? [String: Any],
                  let code = dict["code"] as? String else {
                return
            }
            if code == "start-mic-ios" {
                // Start text to speech
                // After speech, start listening
            }
            let isInternal = dict["internal"] as? Bool ?? false
            if isInternal {
                handleInternalEvent(code: code)
            } else {
                let data = dict["data"] as? String
                delegate?.eventReceivedFromBot(code: code, data: data)
            }
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in completionHandler() })
        self.present(alertController, animated: true, completion: nil)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

extension YMChatViewController: WKUIDelegate {
    // for <buttons> in html that have window.open
    // https://stackoverflow.com/questions/33190234/wkwebview-and-window-open
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        return nil
    }
}

/// WKUserContentController retains its message handler.
///
/// https://stackoverflow.com/a/26383032/1311902
fileprivate class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?

    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
