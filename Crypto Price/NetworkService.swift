//
//  NetworkService.swift
//  Crypto Price
//
//  Created by Andrew Kvasha on 09.09.2022.
//

import Foundation


final class NetworkService {
    static let shared = NetworkService()
    
    private struct Constants {
        static let apiKey = "4FDBE7F6-BEED-4932-BEC4-37185C2BD2EE"                //"65d826b99ad9177574292332ff03b21ca80d24b6"
        static let assetsEndPoint = "https://rest-sandbox.coinapi.io/v1/assets/"                //"https://api.nomics.com/v1/currencies/"
    }
    
    private init() {}
    
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error >) -> Void)?

    
    public func getAllCryptoData(
        completion: @escaping (Result<[Crypto], Error >) -> Void
    ) {
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        guard let url = URL(string: Constants.assetsEndPoint + "?apikey=" + Constants.apiKey) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                completion(.success(cryptos.sorted { first, second in
                    return first.price_usd ?? 0 > second.price_usd ?? 0
                }))
            }
            catch {
                completion(.failure(error))
            }

        }.resume()
    }
    
    public func getAllIcons() {
        guard let url = URL(string: "https://rest.coinapi.io/v1/assets/icons/55/?apikey=4FDBE7F6-BEED-4932-BEC4-37185C2BD2EE")
        else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlock {
                    self?.getAllCryptoData(completion: completion)
                }
            }
            catch {
                print(error)
            }
            
        }
        task.resume()
    }
}
