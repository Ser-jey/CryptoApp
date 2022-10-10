//
//  String.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 05.10.2022.
//

import Foundation


extension String {
    
    var removingHTMLOccurance: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
}
