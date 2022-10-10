//
//  MarketDataService.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 11.09.2022.
//

import Foundation
import Combine

class MarketDataService {
    
    @Published var marketData: MarketDataModel? = nil
    var marketSubscription : AnyCancellable?
    
    init() {
        getData()
    }
    
     func getData() {
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else { return }
     
        marketSubscription = NetworkingManager.download(url: url)
            .decode(type: GloballData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleComplition, receiveValue: { [weak self] (returnedGloballData) in
                self?.marketData = returnedGloballData.data // self создает сильную ссылку
                self?.marketSubscription?.cancel()
            })
        
        
    }
    
}
