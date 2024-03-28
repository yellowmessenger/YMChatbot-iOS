//
//  Image.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 16/02/21.
//

import UIKit

extension Bundle {
    static var assetBundle: Bundle {
        // Returns YellowResources bundle if installed using cocoapods
        // Returns self bundle if installed using xcframework
        //
        // A separate bundle is required when user integrates statically using cocoapods
        
        #if SWIFT_PACKAGE
            return Bundle.module
        #endif
        
        let moduleBundle = Bundle(for: YMChat.self)
        if let url = moduleBundle.url(forResource: "YellowResources", withExtension: "bundle"),
           let imageBundle = Bundle(url: url) {
            return imageBundle
        }
        return moduleBundle
    }
}
