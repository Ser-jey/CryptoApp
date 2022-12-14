//
//  XmarkButton.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 12.09.2022.
//

import SwiftUI

struct XmarkButton: View {
    
     @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

struct XmarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XmarkButton()
            
    }
}
