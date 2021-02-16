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
        return UIImage(named: self.rawValue, in: bundle, compatibleWith: .none)!
    }
}
