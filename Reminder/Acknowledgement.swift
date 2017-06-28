//
//  Acknowledgement.swift
//  Reminder
//
//  Created by Sahn Cha on 06/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import Foundation

struct Acknowledgement {
    
    static var list: [(title: String, content: String?)] {
        return [
            (title: "RxSwift",
             content: license(file: "rxswift")),
            
            (title: "KeyChainAccess",
             content: license(file: "keychainaccess")),
            
            (title: "IDZSwiftCommonCrypto",
             content: license(file: "idzswiftcommoncrypto")),
            
            (title: "Hue",
             content: license(file: "hue"))
        ]
    }
    
    static func license(file: String) -> String? {
        let path = Bundle.main.path(forResource: file, ofType: "txt")
        
        if let p = path {
            do {
                return try String(contentsOfFile: p, encoding: .utf8)
            }
            catch { return nil }
        }
        return nil
    }
    
}
