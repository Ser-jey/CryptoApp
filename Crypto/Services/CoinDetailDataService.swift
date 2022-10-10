//
//  CoinDetailDataService.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 25.09.2022.
//

import Foundation
import Combine

class CoinDetailDataService {
    
    @Published var coinDetails: CoinDetailModel?
    var coinDetailSubscription : AnyCancellable?
    let coin: CoinModel
    
    init(coin: CoinModel) {
        self.coin = coin
        getCoinDetails()
    }
    
     func getCoinDetails() {
         guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else { return }
print(url)
         coinDetailSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleComplition, receiveValue: { [weak self] (returnedCoins) in
                self?.coinDetails = returnedCoins // self создает сильную ссылку
                print((self?.coinDetails?.hashingAlgorithm ?? "") + "Service" ?? "not Service")
                self?.coinDetailSubscription?.cancel()
            })
        
        
    }
    
}
