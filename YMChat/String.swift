//
//  String.swift
//  YMChat
//
//  Created by Sankalp Gupta on 22/12/21.
//

import Foundation

extension String {
    
    var isImageType: Bool {
        let imageFormats = ["jpeg", "jpg", "png", "gif", "svg"]
        
        if let url = URL(string: self)  {
            
            let format = url.pathExtension
            return imageFormats.contains(format)
        }
        return false
    }
}
