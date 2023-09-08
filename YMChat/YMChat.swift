import UIKit

@objc(YMChatDelegate)
public protocol YMChatDelegate {
    @objc optional func onEventFromBot(response: YMBotEventResponse)
    @objc optional func onBotClose()
}

@objc(YMChat)
public class YMChat: NSObject, YMChatViewControllerDelegate {
    @objc public static var shared = YMChat()
    @objc weak public var delegate: YMChatDelegate?

    @objc public var enableLogging = false

    @objc public var viewController: YMChatViewController?
    @objc public var config: YMConfig!

    func validateConfig() throws {
        if config == nil {
            throw NSError(domain: "Config is nil. Set config before invoking startChatbot", code: 0, userInfo: nil)
        }
        if config.botId.isEmpty {
            throw NSError(domain: "Bot id is not set. Please set botId before calling startChatbot()", code: 0, userInfo: nil)
        }
        if config.customBaseUrl.isEmpty {
            throw NSError(domain: "`customBaseURL` should not be empty.", code: 0, userInfo: nil)
        }
        if config.customLoaderUrl.isEmpty || (URL(string: config.customLoaderUrl) == nil) {
            throw NSError(domain: "Please provide valid `customLoaderUrl`", code: 0, userInfo: nil)
        }
        if !(config.version == 1 || config.version == 2) {
            throw NSError(domain: "version can be either 1 or 2", code: 0, userInfo: nil)
        }
        try JSONSerialization.data(withJSONObject: config.payload, options: [])
    }

    func validateConfig(config: YMConfig) throws {
        if config.botId.isEmpty {
            throw NSError(domain: "Bot id is not set. Please set botId before calling startChatbot()", code: 0, userInfo: nil)
        }
        if config.customBaseUrl.isEmpty {
            throw NSError(domain: "`customBaseURL` should not be empty.", code: 0, userInfo: nil)
        }
        if config.customLoaderUrl.isEmpty || (URL(string: config.customLoaderUrl) == nil) {
            throw NSError(domain: "Please provide valid `customLoaderUrl`", code: 0, userInfo: nil)
        }
        if !(config.version == 1 || config.version == 2) {
            throw NSError(domain: "version can be either 1 or 2", code: 0, userInfo: nil)
        }
        try JSONSerialization.data(withJSONObject: config.payload, options: [])
    }

    @discardableResult
    @objc public func initialiseView() throws -> YMChatViewController {
        try validateConfig()
        self.viewController = YMChatViewController(config: config)
        self.viewController?.delegate = self
        return viewController!
    }

    @objc public func startChatbot(on viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) throws {
        try initialiseView()
        viewController.present(self.viewController!, animated: animated, completion: completion)
    }

    @objc public func startChatbot(animated: Bool = true, completion: (() -> Void)? = nil) throws {
        guard let vc = UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController else {
            assertionFailure("View controller not found. Instead use startChatbot(on:animated:completion) and pass view controller as a first parameter")
            return
        }
        try startChatbot(on: vc, animated: animated, completion: completion)
    }

    @objc public func closeBot() {
        viewController?.dismiss(animated: false)
        viewController = nil
    }

    @objc public func reloadBot() throws {
        try validateConfig()
        guard let viewController = viewController else {
            throw NSError(domain: "startChatbot before reloading the bot.", code: 0, userInfo: nil)
        }
        viewController.reloadWebView()
    }

    @objc public func revalidateToken(token: String, refreshSession: Bool) throws {
        if token.isEmpty {
            throw NSError(domain: "Token cannot be empty.", code: 0, userInfo: nil)
        }
        viewController?.handleInternalEvent(code: "ym-revalidate-token", data: YMHelper.getTokenObject(token, refreshSession: refreshSession))
    }

    @available(*, deprecated, renamed: "unlinkDeviceToken(apiKey:ymConfig:success:failure:)")
    @objc public func unlinkDeviceToken(botId: String, apiKey: String, deviceToken: String, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        precondition(!botId.isEmpty && !apiKey.isEmpty && !deviceToken.isEmpty)

        let url = URL(string: "https://app.yellow.ai/api/mobile-backend/device-token")!
        var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponent.queryItems = [URLQueryItem(name: "bot", value: botId)]

        var request = URLRequest(url: urlComponent.url!)

        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")


        let body = ["deviceToken": deviceToken]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        request.httpBody = bodyData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                failure(error!.localizedDescription)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                failure("Failed with status \(code)")
                return
            }
            guard let data = data else {
                failure("Response data empty")
                return
            }
            guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                failure("Invalid response data")
                return
            }
            if let isSuccess = dict["success"] as? Bool {
                if isSuccess {
                    success()
                    return
                }
                let message = dict["message"] as? String ?? "Something went wrong"
                failure(message)
                return
            }
            failure("Something went wrong")
        }.resume()
    }
    
    @objc public func unlinkDeviceToken(apiKey: String, ymConfig: YMConfig, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        precondition(!ymConfig.botId.isEmpty && !apiKey.isEmpty && (ymConfig.deviceToken != nil && !ymConfig.deviceToken!.isEmpty))
        do {
            try validateConfig(config: ymConfig)
            
            let url = URL(string: ymConfig.customBaseUrl + "/api/mobile-backend/device-token")!
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponent.queryItems = [URLQueryItem(name: "bot", value: ymConfig.botId)]
            
            var request = URLRequest(url: urlComponent.url!)
            
            request.httpMethod = "DELETE"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            
            
            let body = ["deviceToken": ymConfig.deviceToken]
            guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                return
            }
            request.httpBody = bodyData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    failure(error!.localizedDescription)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    failure("Failed with status \(code)")
                    return
                }
                guard let data = data else {
                    failure("Response data empty")
                    return
                }
                guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    failure("Invalid response data")
                    return
                }
                if let isSuccess = dict["success"] as? Bool {
                    if isSuccess {
                        success()
                        return
                    }
                    let message = dict["message"] as? String ?? "Something went wrong"
                    failure(message)
                    return
                }
                failure("Something went wrong")
            }.resume()
        } catch {
            failure(error.localizedDescription)
        }
    }
    
    @objc public func registerDevice(apiKey: String, ymConfig: YMConfig, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        precondition(!ymConfig.botId.isEmpty && !apiKey.isEmpty && (ymConfig.deviceToken != nil && !ymConfig.deviceToken!.isEmpty) && (ymConfig.ymAuthenticationToken != nil && !ymConfig.ymAuthenticationToken!.isEmpty))
        
        do {
            try validateConfig(config: ymConfig)
            let url = URL(string: ymConfig.customBaseUrl + "/api/mobile-backend/device-token")!
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponent.queryItems = [URLQueryItem(name: "bot", value: ymConfig.botId)]
            
            var request = URLRequest(url: urlComponent.url!)
            
            request.httpMethod = "PUT"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            
            let body = ["deviceToken": ymConfig.deviceToken!,
                        "ymAuthenticationToken": ymConfig.ymAuthenticationToken!]
            guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                return
            }
            request.httpBody = bodyData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    failure(error!.localizedDescription)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    failure("Failed with status \(code)")
                    return
                }
                guard let data = data else {
                    failure("Response data empty")
                    return
                }
                guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    failure("Invalid response data")
                    return
                }
                if let isSuccess = dict["success"] as? Bool {
                    if isSuccess {
                        success()
                        return
                    }
                    let message = dict["message"] as? String ?? "Something went wrong"
                    failure(message)
                    return
                }
                failure("Something went wrong")
            }.resume()
        } catch {
            failure(error.localizedDescription)
        }
    }

    @objc public func getUnreadMessagesCount(ymConfig: YMConfig, success: @escaping (String) -> Void, failure: @escaping (String) -> Void) {
        precondition(!ymConfig.botId.isEmpty && (ymConfig.ymAuthenticationToken != nil && !ymConfig.ymAuthenticationToken!.isEmpty))

        do {
            try validateConfig(config: ymConfig)
            let url = URL(string: ymConfig.customBaseUrl + "/api/mobile-backend/message/unreadMsgs")!
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponent.queryItems = [URLQueryItem(name: "bot", value: ymConfig.botId)]
            
            var request = URLRequest(url: urlComponent.url!)
            
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            
            let body = ["ymAuthenticationToken": ymConfig.ymAuthenticationToken!]
            guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                return
            }
            request.httpBody = bodyData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    failure(error!.localizedDescription)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    failure("Failed with status \(code)")
                    return
                }
                guard let data = data else {
                    failure("Response data empty")
                    return
                }
                guard let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    failure("Invalid response data")
                    return
                }
                if let isSuccess = dict["success"] as? Bool {
                    if isSuccess, let data = dict["data"] as? [String: Any], let unreadCount = data["unreadCount"] {
                        success("\(unreadCount)")
                        return
                    }
                    let message = dict["message"] as? String ?? "Something went wrong"
                    failure(message)
                    return
                }
                failure("Something went wrong")
            }.resume()
        } catch {
            failure(error.localizedDescription)
        }
    }
    
    // MARK: - YMChatViewControllerDelegate
    func eventReceivedFromBot(code: String, data: String?) {
        if code == "bot-closed" {
            delegate?.onBotClose?()
        } else {
            delegate?.onEventFromBot?(response: YMBotEventResponse(code: code, data: data))
        }
    }
    
    func botCloseButtonTapped() {
        delegate?.onBotClose?()
    }
}
