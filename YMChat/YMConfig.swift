//
//  YMConfig.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 17/02/21.
//

import UIKit

func log(_ items: Any...) {
    if YMChat.shared.enableLogging {
        let output = items.map { "\($0)" }.joined(separator: ", ")
        Swift.print("\(Date()) YMCHAT :: \(output)")
    }
}

@objc(YMConfig)
open class YMConfig: NSObject {
    let botId: String

    @objc public var enableSpeech = false // TODO: Check for default value with Priyank
    @objc public var micButtonColor: UIColor = .white
    @objc public var enableHistory = false // TODO: Check for default value with Priyank

    @objc public var ymAuthenticationToken: String?
    @objc public var deviceToken: String?

//    @objc public var actionBarColor: UIColor // Applicable to Android
    @objc public var statusBarColor: UIColor = .white
//    @objc public var hideCameraForUpload: Bool // Applicable to Android

    @objc public var showCloseButton = true
    @objc public var closeButtonColor: UIColor = .white
    @objc public var customBaseUrl = "https://app.yellowmessenger.com";

    @objc public var payload = [String: Any]()

    @objc public init(botId: String) {
        self.botId = botId
    }

    @objc open var url: URL {
        let localHtml = Bundle.assetBundle.url(forResource: "index", withExtension: "html")!
        var urlComponents = URLComponents(url: localHtml, resolvingAgainstBaseURL: false)!
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "botId", value: botId))
        queryItems.append(URLQueryItem(name: "customBaseUrl", value: customBaseUrl))
        if enableHistory {
            queryItems.append(URLQueryItem(name: "enableHistory", value: "true"))
        }
        if let ymAuthToken = ymAuthenticationToken {
            queryItems.append(URLQueryItem(name: "ymAuthenticationToken", value: ymAuthToken))
        }
        if let deviceToken = deviceToken {
            queryItems.append(URLQueryItem(name: "deviceToken", value: deviceToken))
        }
        if let decodedPayload = decodedPayload {
            queryItems.append(URLQueryItem(name: "ym.payload", value: decodedPayload))
        }
        urlComponents.queryItems = queryItems

        return urlComponents.url!
    }

    /// Payload dict → JSON string  → URL encoding
    var decodedPayload: String? {
        var payload = self.payload
        payload["Platform"] = "iOS-App"
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
              let string = String(data: data, encoding: .utf8),
              let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        return escapedString
    }
}
