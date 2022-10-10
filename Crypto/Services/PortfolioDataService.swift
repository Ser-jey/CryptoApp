//
//  PortfolioDataService.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 13.09.2022.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let requestName: String = "PortfolioEntity"

    @Published var savedEntities: [PortfolioEntity] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
            self.getPortfolio()
        }
    }
    
    // MARK: Public
    func updatePortfolio(coin: CoinModel, amount: Double) {
        print("all enty: \(savedEntities.count)")
        if let coinEntity = savedEntities.first(where: {coin.id == $0.coinID}){
            if amount > 0 {
                update(entity: coinEntity, amount: amount)
                print("func update")
            }
            else {
                delete(entity: coinEntity)
                print("func delete")
            }
        } else {
          add(coin: coin, amount: amount)
            print("func add")
        }
    }

    // MARK: Private
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: requestName)
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Porfolio Entities. \(error)")
        }
    }
    
    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: PortfolioEntity) {
         container.viewContext.delete(entity)
        applyChanges()
    }
    
    //@inline(__always)
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Unable to save data to Core Data: \(error)")
        }
    }
    
    private func applyChanges() {
        save()
        getPortfolio()
    }
    

    
    
    ///
    private func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s.")
}
}
