import UIKit

@objc public protocol YMChatDelegate: AnyObject {
    @objc optional func onEventFromBot(response: YMBotEventResponse)
    @objc optional func onBotClose()
}

@objc public class YMChat: NSObject, YMChatViewControllerDelegate {
    @objc public static var shared = YMChat()
    @objc public var delegate: YMChatDelegate?

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
        viewController?.dismiss(animated: false, completion: {
            self.viewController = nil
        })
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
