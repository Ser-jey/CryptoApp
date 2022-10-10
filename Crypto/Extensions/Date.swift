//
//  Date.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 02.10.2022.
//

import Foundation

extension Date {
    
    init(coinGeckoDateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = formatter.date(from: coinGeckoDateString) ?? Date()
        self.init(timeInterval: 0, since: date)
    }
    
    private var dateShortFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    func asMediumDateString() -> String {
        return dateShortFormatter.string(from: self)
    }
    
}
