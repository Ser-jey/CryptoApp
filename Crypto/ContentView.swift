//
//  ContentView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 31.08.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 10.0) {
                Text("accent")
                    .foregroundColor(Color.theme.accent)
                Text("Sec")
                    .foregroundColor(Color.theme.secondaryText)
                    Text("red")
                    .foregroundColor(Color.theme.red)
                Text("green")
                    .foregroundColor(Color.theme.green)
            }
            .font(.headline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
            
    }
}
