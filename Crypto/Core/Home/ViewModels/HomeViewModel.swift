//
//  HomeViewModels.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 04.09.2022.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var stats: [StatisticModel] = []
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sortOption: SortOption = .holdings
    
    private let portfolioDataService = PortfolioDataService()
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    
    private var cancallables = Set<AnyCancellable>()
    
    enum SortOption {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    init() {
       addSubscribers()
    }
    
    func addSubscribers() {
        
        // По сути этот сабс. нам не нужен так как тоже самое делает саб снизу
        coinDataService.$allCoins
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancallables)
        
        // filter allCoins
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAnsSortCoins)
            .sink { [weak self] filteredCoin in
                    self?.allCoins = filteredCoin
            }
            .store(in: &cancallables)
        
        // set a portfolio from Core Data
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(setPortfolioCoins)
            .sink { [weak self] (returnedCoins) in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIFNeeded(portfolioCoins: returnedCoins)
               
                
            }
            .store(in: &cancallables)
        
        // map market info
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] returnedStats in
                self?.stats = returnedStats
                self?.isLoading = false
            }
            .store(in: &cancallables)
        
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
       portfolioDataService.updatePortfolio(coin: coin, amount: amount)
   }
    
    
    func reloadData() {
        isLoading = true
        coinDataService.getCoin()
        marketDataService.getData()
        HapticManager.notification(type: .success)
    }
    
    private func setPortfolioCoins(allCoins: [CoinModel], savedEntities: [PortfolioEntity]) -> [CoinModel] {
        allCoins.compactMap { (coin) -> CoinModel? in
            guard let entity = savedEntities.first(where: {coin.id == $0.coinID}) else {
                return nil
            }
            return coin.updateHoldings(amount: entity.amount)
        }
    }
    
    
    private func filterAnsSortCoins(text: String, allCoins: [CoinModel], sortOption: SortOption) -> [CoinModel] {
        var updatedCoins = filterCoins(text: text, allCoins: allCoins)
        sortCoins(sort: sortOption, coins: &updatedCoins)
        return updatedCoins
    }
    
    private func sortPortfolioCoinsIFNeeded( portfolioCoins: [CoinModel]) -> [CoinModel] {
        switch sortOption {
        case .holdings :
            return portfolioCoins.sorted(by: {$0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingsReversed:
            return portfolioCoins.sorted(by: {$0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return portfolioCoins
        }
    }
    
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]) { // long-term reference
        switch sort {
            
        case .rank, .holdings:
             coins.sort(by: {$0.rank < $1.rank}) // sort не создает новый объект, а изменяет данный массив
        case .rankReversed, .holdingsReversed:
             coins.sort(by: {$0.rank > $1.rank})
        case .price:
             coins.sort(by: {$0.currentPrice > $1.currentPrice})
        case .priceReversed:
             coins.sort(by: {$0.currentPrice < $1.currentPrice})
        }
    }
    
    private func filterCoins(text: String, allCoins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else { return allCoins }
        
        let lowerCasedText = text.lowercased()
        
        return allCoins.filter { coin in
            coin.name.lowercased().contains(lowerCasedText) ||
            coin.symbol.contains(lowerCasedText) ||
            coin.id.lowercased().contains(lowerCasedText)
        }
    }
    
   
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel]  {
        
        var stats:[StatisticModel] = []

         guard let data = marketDataModel else {
            return []
        }
        
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        
        let volume = StatisticModel(title: "Market Volume", value: data.volume)
        
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        let portfolioValue =
        portfolioCoins
            .map({ $0.currentHoldingsValue })
            .reduce(0, +)
        
        let previousValue = portfolioCoins.map { (coin) -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = (coin.priceChangePercentage24H ?? 0) / 100
            let previousValue = currentValue / (1 + percentChange)
            return previousValue
        }.reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let portfolio =  StatisticModel(title: "Portfolio Value", value: portfolioValue.formattedWithAbbreviations(), percentageChange: percentageChange)
        stats.append(contentsOf: [ marketCap, volume, btcDominance, portfolio ])
        return stats
      
    }
    
}
