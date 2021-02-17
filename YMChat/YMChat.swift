import UIKit

public class YMChat {
    public static var shared = YMChat()
    
    public var viewController: YMChatViewController?
    public var config: YMConfig!
    
    public func presentView(on viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard config != nil else { fatalError("`config` is nil. Set config before invoking presentView") }
        if self.viewController == nil {
            self.viewController = YMChatViewController(config: config)
        }
        viewController.present(self.viewController!, animated: animated, completion: completion)
    }
    
    public func close() {
        viewController = nil
    }

    public func changeLanguage(str: String) {
    }
    
//    func eventReceived(@escaping event: (eventName: String) -> Void)
}
