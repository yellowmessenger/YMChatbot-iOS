//
//  Image.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 16/02/21.
//

import UIKit
//enum Asset {
//    enum Image: String {
//        case stop, mic, close
//
//        var uiImage: UIImage {
//            let bundle = Bundle(for: YMChatViewController.self)
//            if let url = bundle.url(forResource: "YMImages", withExtension: "bundle") {
//                let imageBundle = Bundle(url: url)
//                return UIImage(named: self.rawValue, in: imageBundle, compatibleWith: nil) ?? UIImage()
//            }
//            return UIImage()
//        }
//    }
//
//    static var indexHtml: URL? {
//        assetBundle.url(forResource: "index", withExtension: "html")
//    }
//
//    static var assetBundle: Bundle {
//        // Returns YMImages bundle if installed using cocoapods
//        // Returns framework self bundle is installed using xcframework
//        // A separate bundle is required when user integrates statically using cocoapods
//        let moduleBundle = Bundle(for: YMChat.self)
//        if let url = moduleBundle.url(forResource: "YMImages", withExtension: "bundle"),
//           let imageBundle = Bundle(url: url) {
//            return imageBundle
//        }
//        return moduleBundle
//    }
//}

//enum Image: String {
//    case stop, mic, close
//
//    var uiImage: UIImage {
//        let bundle = Bundle(for: YMChatViewController.self)
//        if let url = bundle.url(forResource: "YMImages", withExtension: "bundle") {
//            let imageBundle = Bundle(url: url)
//            return UIImage(named: self.rawValue, in: imageBundle, compatibleWith: nil) ?? UIImage()
//        }
//        return UIImage()
//    }
//}

extension Bundle {
    static var assetBundle: Bundle {
        // Returns YMImages bundle if installed using cocoapods
        // Returns framework self bundle is installed using xcframework
        // A separate bundle is required when user integrates statically using cocoapods
        let moduleBundle = Bundle(for: YMChat.self)
        if let url = moduleBundle.url(forResource: "YMImages", withExtension: "bundle"),
           let imageBundle = Bundle(url: url) {
            return imageBundle
        }
        return moduleBundle
    }
}
