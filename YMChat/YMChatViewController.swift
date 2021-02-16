//
//  YMChatViewController.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 12/02/21.
//

import Foundation
import UIKit
import WebKit
import Speech

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

    var webView = WKWebView()
    let config: YMConfig
    let progressView = UIProgressView(progressViewStyle: .default)
    lazy var recordDebouncer: Debouncer = Debouncer(timeInterval: 1.5)

    init(config: YMConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(config:) instead")
    }
    
    public override func viewDidLoad() {
        addWebView()
        if config.showCloseButton {
            addCloseButton(tintColor: config.closeButtonColor)
        }
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        if config.enableSpeech, (speechStatus == .authorized || speechStatus == .notDetermined) {
            addMicButton(tintColor: config.micButtonColor)
        }
        addProgressBar()
        recordDebouncer.handler = {
            self.stopListening()
        }
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
        func handleRecordAfterAuthorised() {
            if audioEngine.isRunning {
                stopListening()
            } else {
                startListening()
            }
        }

        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized: handleRecordAfterAuthorised()
        case .denied:
            let alert = UIAlertController(title: "Speech not enabled", message: "Enable speech recognization from Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            askSpeechPermission(onAuthorize: handleRecordAfterAuthorised)
        case .restricted:
            // User has restricted access
            break
        @unknown default: break
        }
    }

    func askSpeechPermission(onAuthorize: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] (status) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .denied, .restricted:
                    self.micButton.removeFromSuperview()
                case .authorized: onAuthorize()
                case .notDetermined: break
                @unknown default: break
                }
            }
        }
    }

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "en-US"))

    func startListening() {
        showSpeechDisplayTextView()
        micButton.isListening = true
        startSpeechReconginzation()
    }

    func stopListening() {
        audioEngine.stop()
        micButton.isListening = false
        speechDisplayTextView.removeFromSuperview()
        recognitionRequest?.endAudio()
    }

    func startSpeechReconginzation() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        recordDebouncer.renewInterval()
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            var isFinal = false

            if let result = result {
                // Update the text view with the results.
                self.speechDisplayTextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }


            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
            self.recordDebouncer.renewInterval()
//            self.restartSpeechTimer()
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }

        speechDisplayTextView.text = "Say something, I'm listening!"

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

extension YMChatViewController: WKNavigationDelegate {
    
}
