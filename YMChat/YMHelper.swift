//
//  YMHelper.swift
//  YMChat
//
//  Created by Sankalp Gupta on 08/09/23.
//

import Foundation

class YMHelper {
    
    static func getTokenObject(_ token: String, refreshSession: Bool) -> String? {
        let dictionary: [String: Any] = ["token": token,
                          "refreshSession": refreshSession]
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
        
        if let data = data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
