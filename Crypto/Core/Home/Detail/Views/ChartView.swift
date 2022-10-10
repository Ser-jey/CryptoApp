//
//  ChartView.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 02.10.2022.
//

import SwiftUI

struct ChartView: View {
    
    private let data: [Double]
    private let maxY: Double
    private let minY: Double
    private let lineColor: Color
    private let startingDate: Date
    private let endingDate: Date
    @State private var percentage: CGFloat = 0
    
    init(coin: CoinModel) {
        self.data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        
        endingDate = Date(coinGeckoDateString: coin.lastUpdated ?? "")
        startingDate = endingDate.addingTimeInterval(7*24*60*60)
    }
    
    //Logic
    /*
     3
     1 * 3 = 1
     2 * 3 = 6
     3 * 3 = 9
     ... 100 * 3 = 300
     
     60,000 - max
     50,000 - min
     60,000 - 50,000 = 10,000 - yAxis
     52,000 - data point
     52.000 - 50,000 = 2,000 / 10,000 = 20%
     */
    
    var body: some View {
        VStack {
                chartView
                    .frame(height: 200)
                    .background(chartBackground)
                    .overlay (chartYAxis.padding(4), alignment: .leading)
                HStack {
                    chartDateLabels
                        .padding(4)
                        
                }
        }
        .font(.caption)
        .foregroundColor(Color.theme.secondaryText)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.linear(duration: 1.8)) {
                    percentage = 1
                }
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(coin: dev.coin)
    }
}

extension ChartView {
    
    private var chartView: some View {
        
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    
                    let YAxis = maxY - minY
                    let yPosition = CGFloat(1 - (data[index] - minY) / YAxis) * geometry.size.height
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }
                      path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    
                }
                
            }
            .trim(to: percentage)
            .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        .foregroundColor(lineColor)
        .shadow(color: lineColor.opacity(UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.5), radius: 10 ,x: 0 , y: 10)
        
        }
        
    }
    
    private var chartBackground: some View {
        VStack {
            Divider()
            Spacer()
            Divider()
            Spacer()
            Divider()
        }
    }
    
    private var chartYAxis: some View {
        VStack {
            Text(maxY.formattedWithAbbreviations())
            Spacer()
            Text(((maxY + minY) / 2).formattedWithAbbreviations())
            Spacer()
            Text(minY.formattedWithAbbreviations())
        }
    }
    
    private var chartDateLabels: some View {
        HStack {
            Text(startingDate.asMediumDateString())
            Spacer()
            Text(endingDate.asMediumDateString())
        }
    }
}
