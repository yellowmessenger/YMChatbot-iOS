//
//  YMConfigTests.swift
//  YMChatTests
//
//  Created by Kauntey Suryawanshi on 17/02/21.
//

import XCTest
@testable import YMChat

class YMConfigTests: XCTestCase {

    func testExample() throws {
        var config = YMConfig()
        config.botId = "x123f34123"
        XCTAssertEqual(config.url.absoluteString, "https://app.yellowmessenger.com/pwa/live/x123f34123?enableHistory=true&ym.payload=%257B%2522Platform%2522%253A%2522iOS-App%2522%257D")
    }

    func testHistoryDisable() {
        var config = YMConfig()
        config.botId = "x123f34123"

        config.enableHistory = false
        XCTAssertEqual(config.url.absoluteString, "https://app.yellowmessenger.com/pwa/live/x123f34123?ym.payload=%257B%2522Platform%2522%253A%2522iOS-App%2522%257D")
    }
}
