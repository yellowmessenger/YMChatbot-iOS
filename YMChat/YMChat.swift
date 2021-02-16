import UIKit

public struct YMConfig {
    public var botId: String?
    
    public var enableSpeech = false // TODO: Check for default value with Priyank
    public var micButtonColor: UIColor = .white
    public var enableHistory = true // TODO: Check for default value with Priyank
    
//    public var actionBarColor: UIColor // TODO: Is this required? What does this do?
//    public var statusBarColor: UIColor // TODO: Is this required? What does this do?
//    public var hideCameraForUpload: Bool // TODO: Is this required? What does this do?
    
    public var showCloseButton = true
    public var closeButtonColor: UIColor = .white
           
    
    public var config: [String: String] = [:]
    public var payload: [String: String] = [:]

    var url: URL {
        guard let botId = botId else { fatalError("`botId` is not set") }
        let urlString = "https://app.yellowmessenger.com/pwa/live/\(botId)"
        return URL(string: urlString)!
    }
}

public class YMChat {
    public static var shared = YMChat()
    
    public var viewController: YMChatViewController?
    public var config = YMConfig()
    
    public func presentView(on viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard config.botId != nil else { fatalError("`botid` is not set") }
        if self.viewController == nil {
            self.viewController = YMChatViewController(config: config)
        }
        viewController.present(self.viewController!, animated: animated, completion: completion)
    }
    
    public func close() {
        viewController = nil
    }
    
//    static func present(in viewController: UIViewController)
//    static func push(in navController: UINavigationController)
//    static eventReceived(@escaping event: (eventName: String) -> Void)
}

