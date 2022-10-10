//
//  SearchBarView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 09.09.2022.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                    searchText.isEmpty ?
                    Color.theme.secondaryText : Color.theme.accent )
            
            TextField("Serch by name or symbol", text: $searchText)
                .foregroundColor(Color.theme.accent)
                .disableAutocorrection(true)
                .overlay (
                    Image(systemName:"xmark")
                        .foregroundColor(
                            searchText.isEmpty ?
                            Color.theme.secondaryText : Color.theme.accent)
                        .padding()
                        .background(Color.theme.background)
                        .opacity(searchText.isEmpty ? 0 : 1)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                UIApplication.shared.endEditing()
                                searchText = ""
                            }
                        }
                        , alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.theme.background)
            .shadow(color: Color.theme.accent.opacity(0.15), radius: 10)
        )
        .padding([.horizontal, .top])
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBarView(searchText: .constant("sg"))
                .previewLayout(.sizeThatFits)
                .padding(.bottom)
            
            SearchBarView(searchText: .constant(""))
                .previewLayout(.sizeThatFits)
                .padding(.bottom)
        }
    }
}
