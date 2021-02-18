//
//  YMConfig.swift
//  YMChat
//
//  Created by Kauntey Suryawanshi on 17/02/21.
//

import UIKit

func log(_ items: Any...) {
    if YMChat.shared.config.enableLogging {
        let output = items.map { "\($0)" }.joined(separator: ", ")
        Swift.print("YMCHAT :: \(output)")
    }
}

open class YMConfig {
    var botId: String

    public var enableSpeech = false // TODO: Check for default value with Priyank
    public var micButtonColor: UIColor = .white
    public var enableHistory = true // TODO: Check for default value with Priyank

//    public var actionBarColor: UIColor // Applicable to Android
    public var statusBarColor: UIColor = .white
//    public var hideCameraForUpload: Bool // Applicable to Android

    public var showCloseButton = true
    public var closeButtonColor: UIColor = .white

    public var payload = [String: String]()
    public var enableLogging = false

    public init(botId: String) {
        self.botId = botId
    }

    open var url: URL {
        var urlComponents = URLComponents()
        urlComponents.host = "app.yellowmessenger.com"
        urlComponents.scheme = "https"
        urlComponents.path = "/pwa/live/\(botId)"
        var queryItems = [URLQueryItem]()
        if enableHistory {
            queryItems.append(URLQueryItem(name: "enableHistory", value: "true"))
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
