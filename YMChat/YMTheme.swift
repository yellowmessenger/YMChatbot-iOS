//
//  YMTheme.swift
//  YMChat
//
//  Created by Sankalp Gupta on 08/11/23.
//

import UIKit

@objc(YMTheme)
public class YMTheme: NSObject, Encodable {
    @objc public var botName: String?
    @objc public var primaryColor: UIColor?
    @objc public var secondaryColor: UIColor?
    @objc public var botIcon: String?
    @objc public var botDescription: String?
    @objc public var botClickIcon: String?
    
    enum CodingKeys: CodingKey {
        case botName
        case primaryColor
        case secondaryColor
        case botIcon
        case botDesc
        case botClickIcon
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.botName, forKey: .botName)
        try container.encodeIfPresent(self.primaryColor?.hex, forKey: .primaryColor)
        try container.encodeIfPresent(self.secondaryColor?.hex, forKey: .secondaryColor)
        try container.encodeIfPresent(self.botIcon, forKey: .botIcon)
        try container.encodeIfPresent(self.botDescription, forKey: .botDesc)
        try container.encodeIfPresent(self.botClickIcon, forKey: .botClickIcon)
    }
}
