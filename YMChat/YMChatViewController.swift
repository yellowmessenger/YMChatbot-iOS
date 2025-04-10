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

    private var micBottomConstraint: NSLayoutConstraint?
    private var micRightConstraint: NSLayoutConstraint?

    init(config: YMConfig) {
        self.config = config
        self.micButton = MicButton(config.speechConfig)
        super.init(nibName: nil, bundle: nil)
        if speechEnabled {
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
        if speechEnabled {
            addMicButton()
        }
        if config.showCloseButton {
            addCloseButton(tintColor: config.closeButtonColor)
        }
        log("Loading URL: \(config.url)")
        if #available(iOS 16.4, *) {
            webView?.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        webView?.load(URLRequest(url: config.url))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterInBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterInForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationDidEnterInBackground(notification: Notification) {
        delegate?.eventReceivedFromBot(code: "chatbot-in-background", data: nil)
    }
    
    @objc func applicationWillEnterInForeground(notification: Notification) {
        delegate?.eventReceivedFromBot(code: "chatbot-in-foreground", data: nil)
    }

    func reloadWebView() {
        webView?.load(URLRequest(url: config.url))
    }

    private func addWebView() {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let js = "function sendEventFromiOS(eventCode, eventData){document.getElementById('ymIframe').contentWindow.postMessage(JSON.stringify({ event_code: eventCode, data: eventData }), '*');}"
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        contentController.add(LeakAvoider(delegate:self), name: "ymHandler")
        
        let scriptSource = "window.addEventListener('error', function(event){ if(event.target.tagName === 'SCRIPT'){ window.webkit.messageHandlers.ymResourceError.postMessage(event.target.src);}}, true);"
        let ymResourceErrorScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(ymResourceErrorScript)
        contentController.add(LeakAvoider(delegate:self), name: "ymResourceError")
        
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
        micBottomConstraint = micButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: config.version == 1 ? -70 : -90)
        micRightConstraint = micButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10)
        NSLayoutConstraint.activate([micBottomConstraint!, micRightConstraint!])
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        if config.speechConfig.isButtonMovable {
            micButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(micButtonDragged)))
        }
    }
    
    private func addErrorView() {
        let errorView = YMErrorView()
        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.widthAnchor.constraint(equalTo: view.widthAnchor),
            errorView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }

    @objc func micButtonDragged(gesture: UIPanGestureRecognizer){
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location

        if gesture.state == .ended {
            if self.micButton.frame.midY >= self.view.layer.frame.height - 115 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.micButton.center.y = self.view.layer.frame.height - 115
                }, completion: nil)
            }
            
            if self.micButton.frame.midX >= self.view.layer.frame.width - 35 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.micButton.center.x = self.view.layer.frame.width - 35
                }, completion: nil)
            } else if self.micButton.frame.midX <= 35 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.micButton.center.x = 35
                }, completion: nil)
            }

            let translation = gesture.translation(in: micButton)
            micRightConstraint?.constant += translation.x
            micBottomConstraint?.constant += translation.y
            if micRightConstraint!.constant > -10 {
                micRightConstraint?.constant = -10
            } else if micRightConstraint!.constant < (-1 * self.view.frame.width) + 60 {
                micRightConstraint?.constant = (-1 * self.view.frame.width) + 60
            }
            
            if micBottomConstraint!.constant > -90 {
                micBottomConstraint?.constant = -90
            } else if micBottomConstraint!.constant < (-1 * self.view.frame.height) + 120 {
                micBottomConstraint?.constant = (-1 * self.view.frame.height) + 120
            }
        }
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

    func sendEventToWebView(code: String, data: Any) {
        log(#function, code, data)
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("sendEventFromiOS('\(code)', '\(data)');", completionHandler: nil)
        }
    }

    private var errorPathsToValidate = [
        "/widget/mobile.js",
        "/widget/v2/mobile.js",
        "/plugin/latest/dist/mobile.min.js",
        "/plugin/latest/dist/widget.min.js",
        "/plugin/widget-v2/latest/dist/mobile.min.js",
        "/plugin/widget-v2/latest/dist/widget.min.js"
    ]
}

private extension YMChatViewController {
    private var speechEnabled: Bool {
        config.enableSpeech || config.speechConfig.enableSpeech
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
            sendEventToWebView(code: "send-voice-text", data: speechDisplayTextView.text ?? "")
        }
    }

    func handleInternalEvent(code: String, data: String? = nil) {
        switch code {
        case "image-opened":
            closeButton.isHidden = true
            if speechEnabled {
                micButton.isHidden = true
            }
        case "image-closed":
            closeButton.isHidden = false
            if speechEnabled {
                micButton.isHidden = false
            }
        case "close-bot":
            delegate?.eventReceivedFromBot(code: "bot-closed", data: nil)
        case "ym-revalidate-token":
            if let data = data {
                sendEventToWebView(code: "revalidate-token", data: data)
            }
        case "send-event-to-bot":
            if let data = data {
                sendEventToWebView(code: "event-from-client", data: data)
            }
        default: break
        }
    }
}

extension YMChatViewController: WKNavigationDelegate, WKScriptMessageHandler {
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "ymResourceError" {
            guard let failedResourceUrl = message.body as? String else { return }
            if (errorPathsToValidate.contains { failedResourceUrl.contains($0) }) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    addErrorView()
                    if (config.showCloseButton && config.closeButtonColor == .white) {
                        closeButton.tintColor = .black
                    }
                    self.view.bringSubviewToFront(closeButton)
                    webView?.isHidden = true
                    delegate?.eventReceivedFromBot(code: "bot-load-failed", data: nil)
                }
            }
        }
        
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
        guard navigationAction.navigationType == .linkActivated,
              let url = navigationAction.request.url,
              UIApplication.shared.canOpenURL(url) else {
            decisionHandler(.allow)
            return
        }
        
        if config.shouldOpenLinkExternally {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            let urlPayload = ["url": url.absoluteString]
            guard let urlData = try? JSONSerialization.data(withJSONObject: urlPayload),
                  let urlString = String(data: urlData, encoding: .utf8) else {
                decisionHandler(.cancel)
                return
            }
            
            delegate?.eventReceivedFromBot(code: "url-clicked", data: urlString)
            decisionHandler(.cancel)
        }
    }
}

extension YMChatViewController: WKUIDelegate {
    // for <buttons> in html that have window.open
    // https://stackoverflow.com/questions/33190234/wkwebview-and-window-open
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if config.shouldOpenLinkExternally, let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
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

fileprivate class YMErrorView: UIView {
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "ym_technical_issue", in: Bundle.assetBundle, compatibleWith: nil))
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor(red: 116/255, green: 123/255, blue: 127/255, alpha: 1.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "We are facing a technical issue right now. Please try again later."
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8)
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
