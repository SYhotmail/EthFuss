//
//  ExploreMainScreenViewModel+BlockRow.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//

import Foundation
import Combine
import EthCore

typealias ExploreMainScreenRowViewModel = ExploreMainScreenViewModel.BlockViewModel

extension ExploreMainScreenViewModel {
    enum BlockState {
        case pending
        case mined
    }
    
    final class BlockViewModel: ObservableObject, Identifiable {
        
        enum TransactionInfo {
            case raw(hash: String)
            case viewModel(_ viewModel: TransactionViewModel)
            
            var isViewModel: Bool {
                viewModel != nil
            }
            
            var viewModel: TransactionViewModel? {
                if case .viewModel(let innerVM) = self {
                    return innerVM
                }
                return nil
            }
        }
        
        
        var id: String { blockHash }
        let blockHash: String
        let blockNumber: UInt64?
        let timestampTitle: String
        let unixTimestamp: TimeInterval
        let blockState: BlockState
        let reward: String?
        let miner: String
        let transactions: [TransactionInfo]
        let burnedFee: Decimal?
        let uncles: [String]
        
        @Published var transactionReward: String?
        
        
        init(blockHash: String,                 // The hash of the block
             blockNumber: UInt64?,
             unixTimestamp: TimeInterval,
             reward: String?,
             miner: String,
             burnedFee: Decimal?,
             uncles: [String],
             transactions: [TransactionInfo]) {
            
            self.burnedFee = burnedFee
            self.blockHash = blockHash
            self.blockNumber = blockNumber
            self.uncles = uncles
            self.miner = miner
            
            blockState = blockNumber != 0 ? .mined : .pending
            self.unixTimestamp = unixTimestamp
            timestampTitle = TransactionViewModel.timeAgo(unixTimestamp: unixTimestamp)
            self.reward = reward
            
            self.transactions = transactions
            

            scheduleTranscationRewardOnNeed()
        }
        
        
        private func scheduleTranscationRewardOnNeed() {
            let realTransactions = transactions.compactMap { $0.viewModel }
            
            guard !realTransactions.isEmpty else {
                return
            }
            
            Task {
                var finalEth = realTransactions.reduce(Decimal(0)) { partialResult, vm in
                    guard let fee = try? vm.transactionFee() else {
                        return partialResult
                    }
                    return partialResult + fee
                }
                
                if let rewardRaw = try self.reward?.hexToUInt64() {
                    finalEth += Decimal(rewardRaw)
                }
                
                guard finalEth.isNormal else {
                    assert(!finalEth.isNaN)
                    return
                }
                
                let ethToWeiScale: Decimal = 1_000_000_000_000_000_000  // 1 ETH in wei pow(10, 18)
                assert(ethToWeiScale.isNormal)
                
                finalEth = (finalEth - (self.burnedFee ?? 0))/ethToWeiScale
                
                
                //TODO: find out why it is 0
                let baseBlockReward: Decimal = 0 //2 ETH // 2 ETH
                
                finalEth += Decimal(uncles.count) * baseBlockReward/Decimal(32)
                finalEth += baseBlockReward
                
                // Create a NumberFormatter
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal  // or .currency, .scientific, etc.
                formatter.maximumFractionDigits = 5 // Limit to 18 decimal places // eth ...
                
                // Convert Decimal to String using NumberFormatter
                
                let decimalString = formatter.string(from: finalEth as NSDecimalNumber)
                await MainActor.run { [weak self] in
                    self?.transactionReward = decimalString.flatMap { $0 + " Eth" }
                }
            }
        }
        
        
        convenience init?(blockObject: EthBlockObjectResult) {
            guard let unixTimestampRaw = try? blockObject.timestamp.hexToUInt64() else {
                return nil
            }
            
            self.init(blockHash: blockObject.hash,
                      blockNumber: try? blockObject.number?.hexToUInt64(),
                      unixTimestamp: TimeInterval(unixTimestampRaw),
                      reward: blockObject.reward,
                      miner: blockObject.miner,
                      burnedFee: try? blockObject.burnedFee(),
                      uncles: blockObject.uncles,
                      transactions: blockObject.transactions.compactMap { transactionObj in
                
                switch transactionObj {
                case .raw(address: let address):
                    return .raw(hash: address)
                case .object(let transactionObject):
                    guard let viewModel = TransactionViewModel(transactionObject: transactionObject) else {
                        return nil
                    }
                    viewModel.setTimestampRaw(blockObject.timestamp)
                    return .viewModel(viewModel)
                }
            })
        }
        
        func blockDetailViewModel() -> EthBlockDetailedViewModel! {
            return .init(blockHash: blockHash,
                         blockNumber: blockNumber)
        }
    }
}
