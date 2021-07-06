//
//  Image.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 16/02/21.
//

import UIKit

extension Bundle {
    static var assetBundle: Bundle {
        // Returns YMImages bundle if installed using cocoapods
        // Returns self bundle if installed using xcframework
        //
        // A separate bundle is required when user integrates statically using cocoapods
        let moduleBundle = Bundle(for: YMChat.self)
        if let url = moduleBundle.url(forResource: "YMImages", withExtension: "bundle"),
           let imageBundle = Bundle(url: url) {
            return imageBundle
        }
        return moduleBundle
    }
}
