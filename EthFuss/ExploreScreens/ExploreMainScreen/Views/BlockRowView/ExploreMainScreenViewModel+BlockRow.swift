//
//  ExploreMainScreenViewModel+BlockRow.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//

import Foundation
import Combine
import EthCore

extension ExploreMainScreenViewModel {
    enum BlockState {
        case pending
        case mined
    }
    
    
    struct TransactionViewModel: Identifiable {
        var id: String { hash }
        let hash: String
        let from: String?
        let to: String?
        let value: String //ETh...
        let gas: String
        let gasPrice: String
        let timestampSubject = CurrentValueSubject<String?, Never>(nil)
        
        nonmutating func setTimestampRaw(_ raw: String) {
            guard let unixTimestampRaw = try? raw.hexToUInt64() else {
                return
            }
            timestampSubject.value = Self.timeAgo(unixTimestamp: TimeInterval(unixTimestampRaw))
        }
        
        init(hash: String, from: String?, to: String?, value: String, gas: String, gasPrice: String) {
            self.hash = hash
            self.from = from
            self.to = to
            self.value = value
            self.gas = gas
            self.gasPrice = gasPrice
        }
        
        init?(transactionObject: EthTransactionObjectResult) {
            self.init(hash: transactionObject.hash,
                      from: transactionObject.from,
                      to: transactionObject.to,
                      value: transactionObject.value,
                      gas: transactionObject.gas,
                      gasPrice: transactionObject.gasPrice)
        }
        
        nonmutating func transactionFee() throws -> Decimal? {
            let gasHex = try gas.hexToUInt64()
            let gasPriceHex = try gasPrice.hexToUInt64()
            guard let gasHex, let gasPriceHex else {
                return nil
            }
            
            return Decimal(gasHex) * Decimal(gasPriceHex)
        }
        
        static func timeAgo(unixTimestamp: TimeInterval) -> String {
            let interval = Date().timeIntervalSince(Date(timeIntervalSince1970: unixTimestamp))
            
            let hours = Int(interval) / 3600
            let format: String
            let value: Int?
            if hours != 0 {
                value = hours
                format = "%d hours ago"
            } else {
                let minutes = (Int(interval) % 3600) / 60
                if minutes != 0 {
                    value = minutes
                    format = "%d mins ago"
                } else {
                    let seconds = Int(interval) % 60
                    if seconds != 0 {
                        value = seconds
                        format = "%d secs ago"
                    } else {
                        value = nil
                        format = "now"
                    }
                }
            }
            
            if let value {
                return .init(format: format, value) //TODO: support localization etc...
            } else {
                return format
            }
        }
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
        
        
        let id: String
        let blockNumber: UInt64?
        let timestamp: String
        let blockState: BlockState
        let reward: String?
        let transactions: [TransactionInfo]
        let burnedFee: Decimal?
        let uncles: [String]
        
        @Published var transactionReward: String?
        
        private init(blockNumber: UInt64?,
                     unixTimestamp: TimeInterval,
                     reward: String?,
                     burnedFee: Decimal?,
                     uncles: [String],
                     transactions: [TransactionInfo]) {
            
            self.burnedFee = burnedFee
            self.blockNumber = blockNumber
            self.uncles = uncles
            self.id = blockNumber?.hexString() ?? UUID().uuidString
            
            
            blockState = blockNumber != 0 ? .mined : .pending
            timestamp = TransactionViewModel.timeAgo(unixTimestamp: unixTimestamp)
            self.reward = reward
            
            self.transactions = transactions
            

            scheduleTranscationRewardOnNeed()
        }
        
        
        private /*nonmutating*/ func scheduleTranscationRewardOnNeed() {
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
            
            self.init(blockNumber: try? blockObject.number?.hexToUInt64(),
                      unixTimestamp: TimeInterval(unixTimestampRaw),
                      reward: blockObject.reward,
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
    }
}
