//
//  YMBotEventResponse.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 23/02/21.
//

import Foundation

@objc(YMBotEventResponse)
public class YMBotEventResponse: NSObject {
    @objc public let code: String
    @objc public let data: String?

    init(code: String, data: String?) {
        self.code = code
        self.data = data
        super.init()
    }

    public override var description: String {
        "[CODE: \(code) DATA: \(data ?? "NIL")"
    }
}
