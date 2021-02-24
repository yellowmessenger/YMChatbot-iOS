//
//  YMBotEventResponse.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 23/02/21.
//

@objc public class YMBotEventResponse: NSObject {
    @objc public let code, data: String

    init(code: String, data: String) {
        self.code = code
        self.data = data
        super.init()
    }

//    var dataToDict: [String: Any] {
//
//    }
}
