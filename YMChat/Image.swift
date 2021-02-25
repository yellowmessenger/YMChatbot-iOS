//
//  Image.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 16/02/21.
//

import UIKit

enum Image: String {
    case stop, mic, close

    var uiImage: UIImage {
        let bundle = Bundle(for: YMChatViewController.self)
        if let url = bundle.url(forResource: "YMImages", withExtension: "bundle") {
            let imageBundle = Bundle(url: url)
            return UIImage(named: self.rawValue, in: imageBundle, compatibleWith: nil) ?? UIImage()
        }
        return UIImage()
    }
}
