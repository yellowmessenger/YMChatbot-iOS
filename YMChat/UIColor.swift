//
//  UIColor.swift
//  YMChat
//
//  Created by Sankalp Gupta on 08/11/23.
//

import UIKit

extension UIColor {
    convenience init?(_ hex: String, alpha: CGFloat? = nil) {

        guard let hexType = Type(from: hex), let components = hexType.components() else {
            return nil
        }

        self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
    }

    /// The string hex value representation of the current color
    var hex: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0, rgb: Int
        getRed(&r, green: &g, blue: &b, alpha: &a)

        if a == 1 { // no alpha value set, we are returning the short version
            rgb = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
            return String(format: "#%06x", rgb)
        } else {
            rgb = (Int)(r * 255) << 24 | (Int)(g * 255) << 16 | (Int)(b * 255) << 8 | (Int)(a * 255) << 0
            return String(format: "#%08x", rgb)
        }
    }

    private enum `Type` {

        case RGBshort(rgb: String)
        case RGB(rgb: String)

        init?(from hex: String) {

            var hexString = hex
            hexString.removeHashIfNecessary()

            guard let t = Type.transform(hex: hexString) else {
                return nil
            }

            self = t
        }

        static func transform(hex string: String) -> Type? {
            switch string.count {
            case 3:
                return .RGBshort(rgb: string)
            case 6:
                return .RGB(rgb: string)
            default:
                return nil
            }
        }

        var value: String {
            switch self {
            case .RGBshort(let rgb):
                return rgb
            case .RGB(let rgb):
                return rgb
            }
        }

        typealias RGBComponents = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
        func components() -> RGBComponents? {

            var hexValue: UInt32 = 0
            guard Scanner(string: value).scanHexInt32(&hexValue) else {
                return nil
            }

            let r, g, b, a, divisor: CGFloat

            switch self {
            case .RGBshort:
                divisor = 15
                r = CGFloat((hexValue & 0xF00) >> 8) / divisor
                g = CGFloat((hexValue & 0x0F0) >> 4) / divisor
                b = CGFloat( hexValue & 0x00F) / divisor
                a = 1
            case .RGB:
                divisor = 255
                r = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
                g = CGFloat((hexValue & 0x00FF00) >> 8) / divisor
                b = CGFloat( hexValue & 0x0000FF) / divisor
                a = 1
            }

            return (red: r, green: g, blue: b, alpha: a)
        }
    }
}

private extension String {

  mutating func removeHashIfNecessary() {
    if hasPrefix("#") {
      self = replacingOccurrences(of: "#", with: "")
    }
  }
}
