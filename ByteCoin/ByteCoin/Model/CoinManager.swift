//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Vlad Novik on 6/8/20.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinRate(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "6BD8FF33-6EB8-4F5D-90E4-F207DD6C120E"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = baseURL + "/\(currency)" + "?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coinRate = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCoinRate(self, coin: coinRate)
                    }
                }
            }
            task.resume()
        }
    }
        
        func parseJSON(_ coinData: Data) -> CoinModel? {
            let decoder = JSONDecoder()
            do {
                let deocoderData = try decoder.decode(CoinData.self, from: coinData)
                let coinRate = CoinModel(currencyRate: deocoderData.rate, quote: deocoderData.asset_id_quote)
                return coinRate
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
            
        }

    
    
}
