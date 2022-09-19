//
//  ViewController.swift
//  Crypto Price
//
//  Created by Andrew Kvasha on 09.09.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    private var table = UITableView()
    private var viewModels = [CryptoTableViewCellViewModel]()
    static let numberFormatter: NumberFormatter = {
        let formater = NumberFormatter()
        formater.locale = .current
        formater.allowsFloats = true
        formater.numberStyle = .currency
        formater.formatterBehavior = .default
        
        return formater
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupNavigationBar()
        
        NetworkService.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                self?.viewModels = models.compactMap({ model in
                    let price = model.price_usd ?? 0
                    let formatter = MainViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber(value: price))
                    
                    let iconUrl = URL(
                        string:
                            NetworkService.shared.icons.filter({ icon in
                                icon.asset_id == model.asset_id
                            }).first?.url ?? "")
                    
                    return CryptoTableViewCellViewModel(
                        name: model.name ?? "NO",
                        symbol: model.asset_id,
                        price: priceString ?? "0",
                        iconUrl: iconUrl
                    )
                })
                DispatchQueue.main.async {
                    self?.table.reloadData()
                }
                    
            case .failure(_): break
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTable() {
        self.table = UITableView(frame: view.bounds, style: .grouped)
        self.table.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.identifier)
        
        self.table.delegate = self
        self.table.dataSource = self
        
        view.addSubview(table)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = table.dequeueReusableCell(
            withIdentifier: "CryptoTableViewCell",
            for: indexPath
      ) as? CryptoTableViewCell else {
          print(viewModels)
          fatalError()
      }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "All Crypto"
    }
    
}

