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
    var webView = WKWebView()
    let config: YMConfig
    let progressView = UIProgressView(progressViewStyle: .default)

    init(config: YMConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        speechHelper.delegate = self
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
    
    func addMicButton(tintColor: UIColor) {
        view.addSubview(micButton)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        micButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        micButton.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
    }

    @objc func micTapped() {
        speechHelper.micButtonTapped()
    }
    
    func showSpeechDisplayTextView() {
        self.view.insertSubview(speechDisplayTextView, belowSubview: micButton)
        speechDisplayTextView.translatesAutoresizingMaskIntoConstraints = false
        speechDisplayTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        speechDisplayTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speechDisplayTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        speechDisplayTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
        speechDisplayTextView.text = text
    }

    func listeningStarted() {
        micButton.isListening = true
        showSpeechDisplayTextView()
        speechDisplayTextView.text = "Say something, I'm listening!"
    }

    func listeningCompleted() {
        micButton.isListening = false
        speechDisplayTextView.removeFromSuperview()
    }
}

extension YMChatViewController: WKNavigationDelegate {
    //TODO: Handle this
}
