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
            let image: Image = isListening ? .stop : .mic
            setImage(image.uiImage, for: .normal)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: size, height: size)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(Image.mic.uiImage, for: .normal)
        backgroundColor = UIColor(red: 6/255.0, green: 151/255.0, blue: 232/255.0, alpha: 1.0)
        layer.cornerRadius = size / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
