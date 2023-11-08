//
//  UIColor.swift
//  YMChat
//
//  Created by Sankalp Gupta on 08/11/23.
//

import UIKit

extension UIColor {
    var hex: String? {
        cgColor
            .converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)?
            .components?[0..<3]
            .map { String(format: "%02lX", Int($0 * 255)) }
            .reduce("#", +)
    }
}
