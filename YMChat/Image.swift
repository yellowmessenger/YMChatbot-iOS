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
        // Returns framework self bundle is installed using xcframework
        // A separate bundle is required when user integrates statically using cocoapods
        let moduleBundle = Bundle(for: YMChatBot.self)
        if let url = moduleBundle.url(forResource: "YMImages", withExtension: "bundle"),
           let imageBundle = Bundle(url: url) {
            return imageBundle
        }
        return moduleBundle
    }
}
