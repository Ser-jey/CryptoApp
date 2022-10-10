//
//  CoinImageService.swift
//  Crypto
//
//  Created by Сергей Кривошеев on 06.09.2022.
//

import Foundation
import SwiftUI
import Combine


class CoinImageService {
    
    @Published var image: UIImage? = nil
    var imageSubscription: AnyCancellable?
    
    let fileManager = LocalFileManager.instance
    
    let coin: CoinModel
    let imageName: String
    let folderName: String = "image_cache"
    
    init(coin: CoinModel) {
        self.coin = coin
        self.imageName = coin.name
       getCoinImage()
    }
    
    private func getCoinImage() {
        if let image = fileManager.getImage(imageName: imageName, folderName: folderName) {
            self.image = image
            return
        }
        downloadCoinImage(coin: coin)
    }
    
    private func downloadCoinImage(coin: CoinModel) {
            
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscription = NetworkingManager.download(url: url)
            .tryMap({ (data) -> UIImage? in
                return UIImage(data: data)
            })
            .sink(receiveCompletion: NetworkingManager.handleComplition, receiveValue: { [weak self] (returnedImage) in
                self?.image = returnedImage
                if let image = returnedImage {
                    LocalFileManager.instance.saveImage(image: image, folderName: self!.folderName, imageName: self!.imageName)
                }
                self?.imageSubscription?.cancel()
            })
        
    }
    
}
