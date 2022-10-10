//
//  CoinRowView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 31.08.2022.
//

import SwiftUI

struct CoinRowView: View {
    
    var coin: CoinModel
    let showHoldingsColumn: Bool
    
    var body: some View {
   
            HStack {
                leftColumn
                Spacer()
                if showHoldingsColumn {
                    holdingsColumn
                }
               
                    rightColumn

                .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            }
            .background(Color.theme.background)
            .font(.subheadline)
    }
}

struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CoinRowView(coin: dev.coin, showHoldingsColumn: true)
                .previewLayout(.sizeThatFits)
            
            CoinRowView(coin: dev.coin, showHoldingsColumn: true)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}

extension CoinRowView {
    
    private var leftColumn: some View {
        HStack {
            Text("\(coin.rank)")
                .foregroundColor(Color.theme.secondaryText)
                .frame(minWidth: 30)
     CoinImageView(coin: coin)
                .frame(width: 30, height: 30)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .padding(.leading, 6)
                .foregroundColor(Color.theme.accent)
           
        }
    }
    
    private var holdingsColumn: some View {
        VStack {
            Text("$\(coin.currentHoldingsValue.asNumberString())")
                .bold()
            Text((coin.currentHoldings ?? 0).asNumberString())
                .foregroundColor(Color.theme.accent)
        }
        }
    

private var rightColumn: some View {
    VStack(alignment: .trailing) {
        Text("$\(coin.currentPrice.asNumberString())")
        Text((coin.priceChangePercentage24H?.asPercentString()) ?? "0.00%")
            .foregroundColor(
                (coin.priceChangePercentage24H ?? 0) < 0 ?
                Color.theme.red :
                    Color.theme.green
            )

    }
    
}
}
