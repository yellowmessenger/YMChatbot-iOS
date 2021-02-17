//
//  SpeechHelper.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 17/02/21.
//

import Foundation
import Speech

protocol SpeechDelegate: AnyObject {
    func micButtonTappedWithAuthorizationDenied()
    func micButtonTappedWithAuthorizationRestricted()

    func newText(_ text: String)

    func listeningStarted()
    func listeningCompleted()
}

class SpeechHelper {
    // Stops listening if user does not speak for 1.5 seconds
    lazy var stopListeningDebouncer: Debouncer = Debouncer(timeInterval: 1.5)

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "en-US"))
    weak var delegate: SpeechDelegate?

    init() {
        stopListeningDebouncer.handler = {
            self.stopListening()
        }
    }

    func micButtonTapped() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            if audioEngine.isRunning {
                stopListening()
            } else {
                startListening()
            }
        case .denied:
            delegate?.micButtonTappedWithAuthorizationDenied()
        case .notDetermined:
            askSpeechPermission()
        case .restricted:
            // User has restricted access
            break
        @unknown default: break
        }
    }

    private func askSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] (status) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if status == .authorized {
                    if self.audioEngine.isRunning {
                        self.stopListening()
                    } else {
                        self.startListening()
                    }
                }
            }
        }
    }

    private func startListening() {
        startSpeechReconginzation()
        delegate?.listeningStarted()
    }

    private func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        delegate?.listeningCompleted()
    }

    private func startSpeechReconginzation() {
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

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                self?.delegate?.newText(result.bestTranscription.formattedString)
            }

            if error != nil || (result?.isFinal ?? false) {
                self?.stopListening()
            }
            self?.stopListeningDebouncer.renewInterval()
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
    }
}

