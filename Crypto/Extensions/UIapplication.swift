//
//  UIapplication.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 09.09.2022.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
