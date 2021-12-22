//
//  String.swift
//  YMChat
//
//  Created by Sankalp Gupta on 22/12/21.
//

import Foundation
import UIKit
extension String {
    
    var isImageType: Bool {
        if let url = URL(string: self) {
            do {
                _ = try UIImage(data: Data(contentsOf: url))
                return true
            } catch {
                
            }
        }
        return false
    }
}
