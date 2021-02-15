import UIKit

public struct YMConfig {
    public struct CloseButton {
        public var visible: Bool
        public var tint: UIColor
    }
    
    public var botId: String
    public var config: [String: String] = [:]
    public var payload: [String: String] = [:]
    public var closeButton = CloseButton(visible: true, tint: .white)
    
    public init(botId: String) {
        self.botId = botId
    }
    
    var url: URL {
        let urlString = "https://app.yellowmessenger.com/pwa/live/\(botId)"
        return URL(string: urlString)!
    }
}

public class YMChat {
    public static var ymConfig: YMConfig?
    static var viewController: YMChatViewController?
    
    public static func buildViewController(config: YMConfig) -> YMChatViewController {
        ymConfig = config
        let chatVC = YMChatViewController(config: config)
        return chatVC
    }
    
    public static func close() {
        
    }
    
//    static func present(in viewController: UIViewController)
//    static func push(in navController: UINavigationController)
//    static eventReceived(@escaping event: (eventName: String) -> Void)
}

