//
//  WalletsViewModel.swift
//  TesserCube
//
//  Created by Cirno MainasuK on 2019-11-12.
//  Copyright © 2019 Sujitech. All rights reserved.
//

import os
import UIKit
import RxSwift
import RxCocoa

class WalletsViewModel: NSObject {
    
    let disposeBag = DisposeBag()
    
    var diffableDataSource: UITableViewDataSource!

    // Input
    let currentNetwork = BehaviorRelay(value: EthereumPreference.ethereumNetwork)
    let walletModels = BehaviorRelay<[WalletModel]>(value: [])
    let redPackets = BehaviorRelay<[RedPacket]>(value: [])

    // Output
    let currentWalletModel = BehaviorRelay<WalletModel?>(value: nil)
    let currentWalletPageIndex = BehaviorRelay(value: 0)
    let filteredRedPackets = BehaviorRelay<[RedPacketValue]>(value: [])
    
    enum Section: Int, CaseIterable {
        case wallet
        case redPacket
    }
    
    enum Model: Hashable {
        case wallet
        case redPacket(RedPacketValue)
    }

    override init() {
        super.init()
        
        currentNetwork.asDriver()
            .drive(onNext: { network in
                EthereumPreference.ethereumNetwork = network
            })
            .disposed(by: disposeBag)
        
        // Debug
        currentWalletModel.asDriver()
            .drive(onNext: { walletModel in
                os_log("%{public}s[%{public}ld], %{public}s: currentWalletModel update to %s", ((#file as NSString).lastPathComponent), #line, #function, walletModel?.address ?? "nil")
            })
            .disposed(by: disposeBag)
        
        // Debug
        currentWalletPageIndex.asDriver()
            .drive(onNext: { index in
                os_log("%{public}s[%{public}ld], %{public}s: currentWalletPageIndex update to %s", ((#file as NSString).lastPathComponent), #line, #function, String(index))
            })
            .disposed(by: disposeBag)
        
        // Update current wallet balance when red packet updated
        redPackets.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.currentWalletModel.value?.updateBalance()
            })
            .disposed(by: disposeBag)
        
        // Bind filter for filteredRedPackets on currentWalletModel
        let currentWalletModelChanged = currentWalletModel.asDriver()
            .distinctUntilChanged { lhs, rhs -> Bool in return lhs?.address == rhs?.address }
        Driver.combineLatest(currentWalletModelChanged, redPackets.asDriver()) { currentWalletModel, redPackets -> [RedPacketValue] in
                guard let currentWalletModel = currentWalletModel else {
                    return []
                }
                
                return redPackets.filter { redPacket -> Bool in
                    return redPacket.sender_address == currentWalletModel.address ||
                           redPacket.claim_address == currentWalletModel.address
                }.map { RedPacketValue(redPacket: $0) }
            }
            .drive(filteredRedPackets)
            .disposed(by: disposeBag)
    }

}

@available(iOS 13.0, *)
extension WalletsViewModel {
    
    func configureDataSource(tableView: UITableView) {
        let dataSource = UITableViewDiffableDataSource<Section, Model>(tableView: tableView) { [weak self] tableView, indexPath, model -> UITableViewCell? in
            guard let `self` = self else { return nil }
            os_log("%{public}s[%{public}ld], %{public}s: configure cell at %s", ((#file as NSString).lastPathComponent), #line, #function, String(describing: indexPath))
            return self.constructTableViewCell(for: tableView, atIndexPath: indexPath, with: model)
        }
        dataSource.defaultRowAnimation = .bottom
        diffableDataSource = dataSource
    }
    
}

extension WalletsViewModel {
    
    private func constructTableViewCell(for tableView: UITableView, atIndexPath indexPath: IndexPath, with model: Model) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch model {
        case .wallet:
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletCollectionTableViewCell.self), for: indexPath) as! WalletCollectionTableViewCell
            
            _cell.collectionView.dataSource = self
            
            // Update collection view data source
            walletModels.asDriver()
                .drive(onNext: { [weak self] walletModels in
                    guard let `self` = self else { return }
                    _cell.collectionView.reloadData()
                    
                    guard !walletModels.isEmpty else {
                        self.currentWalletModel.accept(nil)
                        return
                    }
                    
                    let index = self.currentWalletPageIndex.value
                    if index < walletModels.count {
                        // index not move
                        self.currentWalletModel.accept(walletModels[index])
                    } else {
                        // index move 1 step before
                        self.currentWalletModel.accept(walletModels.last)
                        self.currentWalletPageIndex.accept(walletModels.count - 1)
                    }
                })
                .disposed(by: _cell.disposeBag)
            
            // setup page control
            walletModels.asDriver()
                .map { max($0.count, 1) }
                .drive(_cell.pageControl.rx.numberOfPages)
                .disposed(by: _cell.disposeBag)
            currentWalletPageIndex.asDriver()
                .drive(_cell.pageControl.rx.currentPage)
                .disposed(by: _cell.disposeBag)
            
            cell = _cell
            
        // red packet card cell needs filtered red packet model
        case let .redPacket(redPacket):
            let _cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RedPacketCardTableViewCell.self), for: indexPath) as! RedPacketCardTableViewCell
            
            CreatedRedPacketViewModel.configure(cell: _cell, with: redPacket.redPacket)
            
            cell = _cell
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDataSource
extension WalletsViewModel: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        // Section:
        //  - 0: Wallet Section
        //  - 1: Red Packet Section
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.allCases[section] {
        case .wallet:
            return 1
        case .redPacket:
            return filteredRedPackets.value.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model: Model = {
            switch Section.allCases[indexPath.section] {
            case .wallet:
                return .wallet
            case .redPacket:
                return .redPacket(filteredRedPackets.value[indexPath.row])
            }
        }()

        return constructTableViewCell(for: tableView, atIndexPath: indexPath, with: model)
    }

}

// MARK: - UICollectionViewDataSource
extension WalletsViewModel: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return walletModels.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: WalletCardCollectionViewCell.self), for: indexPath) as! WalletCardCollectionViewCell
        
        let walletModel = walletModels.value[indexPath.row]
        WalletsViewModel.configure(cell: cell, with: walletModel)
        
        return cell
    }
    
}