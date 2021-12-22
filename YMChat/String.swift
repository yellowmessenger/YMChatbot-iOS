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
        URL(string: self) != nil
    }
}
