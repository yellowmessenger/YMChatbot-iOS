import UIKit

public class YMChat: YMChatViewControllerDelegate {
    public static var shared = YMChat()

    public var enableLogging = false

    public var viewController: YMChatViewController?
    public var config: YMConfig!

    public var onEventFromBot: ((YMBotEventResponse) -> Void)?

    public func startChatbot(on viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard config != nil else { fatalError("`config` is nil. Set config before invoking presentView") }
        self.viewController = YMChatViewController(config: config)
        self.viewController?.delegate = self
        viewController.present(self.viewController!, animated: animated, completion: completion)
    }

    public func startChatbot(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let vc = UIApplication.shared.windows.last?.rootViewController else {
            assertionFailure("View controller not found. Use presentView(on:animated:completion)")
            return
        }
        startChatbot(on: vc, animated: animated, completion: completion)
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
