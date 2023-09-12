//
//  YMEventModel.swift
//  YMChat
//
//  Created by Sankalp Gupta on 11/09/23.
//

import Foundation

@objc(YMEventModel)
public class YMEventModel: NSObject {
    var code: String
    var data: [String: Any]
    
    public init(code: String, data: [String : Any]) {
        self.code = code
        self.data = data
    }
}
