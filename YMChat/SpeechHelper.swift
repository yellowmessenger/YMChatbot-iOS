//
//  SpeechHelper.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 17/02/21.
//

import Foundation
import Speech

protocol SpeechDelegate: AnyObject {
    func speechPermissionResponseAuthorized()
    func speechPermissionResponseDenied()
    func speechPermissionResponseRestricted()
    func micButtonTappedOnDeniedAuthorization()

    func newText(_ text: String)

    func listeningStarted()
    func listeningCompleted()
}

class SpeechHelper {
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "en-US"))
    weak var delegate: SpeechDelegate?

    var shouldShowMicButton: Bool {
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        return speechStatus == .authorized || speechStatus == .notDetermined
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
            delegate?.micButtonTappedOnDeniedAuthorization()
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
                switch status {
                case .denied: self.delegate?.speechPermissionResponseDenied()
                case .restricted: self.delegate?.speechPermissionResponseRestricted()
                case .authorized:
                    self.delegate?.speechPermissionResponseAuthorized()
                    if self.audioEngine.isRunning {
                        self.stopListening()
                    } else {
                        self.startListening()
                    }

                case .notDetermined: break
                @unknown default: break
                }
            }
        }
    }

    private func startListening() {
//        showSpeechDisplayTextView()
//        micButton.isListening = true
        startSpeechReconginzation()
        delegate?.listeningStarted()
    }

    private func stopListening() {
        audioEngine.stop()
//        micButton.isListening = false
//        speechDisplayTextView.removeFromSuperview()
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

//        recordDebouncer.renewInterval()
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            var isFinal = false

            if let result = result {
                // Update the text view with the results.
                self.delegate?.newText(result.bestTranscription.formattedString)
//                self.speechDisplayTextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
//                print("Text \(result.bestTranscription.formattedString)")
            }


            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
//            self.recordDebouncer.renewInterval()
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
    }
}

