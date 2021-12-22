//
//  String.swift
//  YMChat
//
//  Created by Sankalp Gupta on 22/12/21.
//

import Foundation
import UIKit
extension String {

    var isValidUrl: Bool {
        if URL(string: self) != nil {
            return true
        }
        return false
    }
}
