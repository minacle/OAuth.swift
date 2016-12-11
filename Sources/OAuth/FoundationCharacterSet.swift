//
//  File.swift
//  OAuth
//
//  Created by Sinoru on 2016. 12. 11..
//  Copyright © 2016 Sinoru. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    static var urlUnreservedCharacters: CharacterSet {
        var urlUnreservedCharacters = CharacterSet.alphanumerics
        urlUnreservedCharacters.insert(charactersIn: "-._~")
        return urlUnreservedCharacters
    }
}
