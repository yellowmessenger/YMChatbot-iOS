//
//  MicButton.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 16/02/21.
//

import UIKit

class MicButton: UIButton {
    private let size: CGFloat = 50

    private let rotationAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 1
        animation.isCumulative = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        return animation
    }()

    private lazy var animationLayer: CAShapeLayer = {
        let path = UIBezierPath(arcCenter: CGPoint(x: size / 2, y: size / 2), radius: (size / 2) - 5, startAngle: 0, endAngle: 5, clockwise: true)
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 2
        layer.strokeColor = UIColor.white.cgColor
        layer.path = path.cgPath
        layer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        layer.position = CGPoint(x: 25, y: 25)
        return layer
    }()

    var isListening = false {
        didSet {
            let image: Image = isListening ? .stop : .mic
            setImage(image.uiImage, for: .normal)
            if isListening {
                startAnimation()
            } else {
                stopAnimation()
            }
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

    private func startAnimation() {
        layer.addSublayer(animationLayer)
        animationLayer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    private func stopAnimation() {
        animationLayer.removeAllAnimations()
        animationLayer.removeFromSuperlayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
