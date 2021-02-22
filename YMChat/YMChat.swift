import UIKit

public struct YMBotEventResponse {
    public let code, data: String
//    var dataToDict: [String: Any] {
//
//    }
}

public class YMChat: YMChatViewControllerDelegate {
    public static var shared = YMChat()

    public var enableLogging = false

    public var viewController: YMChatViewController?
    public var config: YMConfig!

    public var onEventFromBot: ((YMBotEventResponse) -> Void)?

    public func presentView(on viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard config != nil else { fatalError("`config` is nil. Set config before invoking presentView") }
        self.viewController = YMChatViewController(config: config)
        self.viewController?.delegate = self
        viewController.present(self.viewController!, animated: animated, completion: completion)
    }

    public func closeBot() {
        viewController?.dismiss(animated: false, completion: {
            self.viewController = nil
        })
    }

    // MARK: - YMChatViewControllerDelegate
    func eventReceivedFromBot(code: String, data: String) {
        onEventFromBot?(YMBotEventResponse(code: code, data: data))
    }
}
