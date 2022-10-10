//
//  CoinDataService.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 04.09.2022.
//

import Foundation
import Combine

class CoinDataService {
    
    @Published var allCoins: [CoinModel] = []
    var coinSubscription : AnyCancellable?
    
    init() {
        getCoin()
    }
    
     func getCoin() {
        print("getCoin called")
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else { return }
     
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleComplition, receiveValue: { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins // self создает сильную ссылку
                self?.coinSubscription?.cancel()
                print("\(self?.allCoins[0].ath ?? 0)")
            })
        
        
    }
    
}
