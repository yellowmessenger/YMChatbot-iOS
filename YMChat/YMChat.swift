import UIKit

public struct YMConfig {
    public var botId: String?
    
    public var enableSpeech = false // TODO: Check for default value with Priyank
    public var micButtonColor: UIColor = .white
    public var enableHistory = true // TODO: Check for default value with Priyank

//    public var actionBarColor: UIColor // Applicable to Android
//    public var statusBarColor: UIColor // TODO: Is this required? What does this do?
//    public var hideCameraForUpload: Bool // Applicable to Android
    
    public var showCloseButton = true
    public var closeButtonColor: UIColor = .white
           
    
//    public var config: [String: String] = [:]
    public var payload: [String: String] = [:]

    var url: URL {
        guard let botId = botId else { fatalError("`botId` is not set") }
        var urlComponents = URLComponents()
        urlComponents.host = "app.yellowmessenger.com"
        urlComponents.scheme = "https"
        urlComponents.path = "/pwa/live/\(botId)"
        var queryItems = [URLQueryItem]()
        if enableHistory {
            queryItems += [URLQueryItem(name: "enableHistory", value: "true")]
        }
        urlComponents.queryItems = [URLQueryItem(name: "enableHistory", value: "true")]
        return urlComponents.url!

//        let urlString = "https://app.yellowmessenger.com/pwa/live/\(botId)"
//        return URL(string: urlString)!
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

    public func changeLanguage(str: String) {
    }
    
//    func eventReceived(@escaping event: (eventName: String) -> Void)
}
