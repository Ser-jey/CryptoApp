//
//  CircleButtonAnimationView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 31.08.2022.
//

import SwiftUI

struct CircleButtonAnimationView: View {
    
    @Binding var animate: Bool
    
    var body: some View {
      Circle()
            .stroke(lineWidth: 5.0)
            .scale(animate ? 1.0 : 0.0)
            .opacity(animate ? 0.0 : 1)
            .animation(animate ? .easeInOut(duration: 1.0) : .none)
            .blur(radius: 3)
         
    }
}

struct CircleButtonAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonAnimationView(animate: .constant(true))
            .frame(width: 100, height: 100)
            .foregroundColor(.red)
    }
}
