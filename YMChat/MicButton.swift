//
//  MicButton.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 16/02/21.
//

import UIKit

class MicButton: UIButton {
    private let size: CGFloat = 50
    
    var isListening = false {
        didSet {
            let imageName: String = isListening ? "stop" : "mic"
            let image = UIImage(named: imageName, in: Bundle.assetBundle, compatibleWith: nil) ?? UIImage()
            setImage(image, for: .normal)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: size, height: size)
    }

    init(_ enableSpeechConfig: YMEnableSpeechConfig) {
        super.init(frame: .zero)
        let image = UIImage(named: "mic", in: Bundle.assetBundle, compatibleWith: nil) ?? UIImage()
        setImage(image, for: .normal)
        backgroundColor = enableSpeechConfig.fabBackgroundColor
        tintColor = enableSpeechConfig.fabIconColor
        layer.cornerRadius = size / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
