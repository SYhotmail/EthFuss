//
//  ExploreMainScreenViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 08/12/2024.
//

import Foundation
import EthCore
import Combine

final class ExploreMainScreenViewModel: ObservableObject {
    
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
        let timestampSubject = CurrentValueSubject<String?, Never>(nil)
        
        nonmutating func setTimestampRaw(_ raw: String) {
            guard let unixTimestampRaw = try? raw.hexToUInt64() else {
                return
            }
            timestampSubject.value = Self.timeAgo(unixTimestamp: TimeInterval(unixTimestampRaw))
        }
        
        init(hash: String, from: String?, to: String?, value: String) {
            self.hash = hash
            self.from = from
            self.to = to
            self.value = value
        }
        
        init?(transactionObject: EthTransactionObjectResult) {
            self.init(hash: transactionObject.hash,
                      from: transactionObject.from,
                      to: transactionObject.to,
                      value: transactionObject.value)
        }
        
        static func timeAgo(unixTimestamp: TimeInterval) -> String {
            let interval = Date().timeIntervalSince(Date(timeIntervalSince1970: unixTimestamp))
            assert(interval >= 0)
            return .init(format: "%0.f mins ago", interval/60) //TODO: support localization etc...
        }
    }
    
    struct BlockViewModel: Identifiable {
        
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
        let transactions: [TransactionInfo]
        
        private init(blockNumber: UInt64?,
                     unixTimestamp: TimeInterval,
                     transactions: [TransactionInfo]) {
            self.blockNumber = blockNumber
            self.id = blockNumber?.hexString() ?? UUID().uuidString
            
            blockState = blockNumber != 0 ? .mined : .pending
            timestamp = TransactionViewModel.timeAgo(unixTimestamp: unixTimestamp)
            self.transactions = transactions
        }
        
        init?(blockObject: EthBlockObjectResult) {
            guard let unixTimestampRaw = try? blockObject.timestamp.hexToUInt64() else {
                return nil
            }
            
            self.init(blockNumber: try? blockObject.number?.hexToUInt64(),
                      unixTimestamp: TimeInterval(unixTimestampRaw),
                      transactions: blockObject.transactions.compactMap { transactionObj in
                switch transactionObj {
                case .raw(address: let address):
                    return .raw(hash: address)
                case .object(let transactionObject):
                    guard let viewModel = TransactionViewModel(transactionObject: transactionObject) else {
                        return nil
                    }
                    return .viewModel(viewModel)
                }
            })
        }
    }
    
    @Published var latestBlocks = [BlockViewModel]()
    @Published var transactions = [TransactionViewModel]()
    
    let connector = EthConnector()
    let blockCount: Int
    let transactionCount: Int
    private var coreTask: Task<(), any Error>!
    
    init(blockCount: Int = 5, transactionCount: Int = 5) {
        self.blockCount = blockCount
        self.transactionCount = transactionCount
        
        defineCoreTask()
    }
    
    private func defineCoreTask() {
        coreTask = Task {
            do {
                let latestBlocks = try await receiveBlocks(number: blockCount)
                
                let transactions: [TransactionViewModel]!
                if let fullBlock = latestBlocks.lazy.first(where: { block in block.transactions.contains { $0.isViewModel } }) {
                    transactions = fullBlock.transactions.compactMap { $0.viewModel }
                } else {
                    transactions = nil
                }
                
                Task { @MainActor in
                    if let transactions {
                        self.transactions = transactions
                    }
                    self.latestBlocks = latestBlocks
                }
            }
            catch {
                debugPrint("!!! Error \(error)")
            }
        }
    }
    
    private func cancelCoreTask() {
        guard let coreTask, !coreTask.isCancelled else {
            return
        }
        coreTask.cancel()
    }
    
    func receiveBlocks(number: Int) async throws -> [BlockViewModel] {
        guard number > 0 else {
            return []
        }
        let blockNumber = try await connector.ethBlockNumber().result
        
        let items = try await withThrowingTaskGroup(of: EthBlockObjectResult.self) { group in
            for i in 0..<number {
                _ = group.addTaskUnlessCancelled {
                    try await self.connector.ethBlockByNumber(tag: .quantity(blockNumber - UInt64(i)) ,full: i == 0).result
                }
            }
            var results = [EthBlockObjectResult]()
            
            guard !group.isEmpty, !group.isCancelled else {
                return results
            }
            
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        let count = items.count
        let retArray = items.compactMap { BlockViewModel(blockObject: $0) }.sorted { $0.id > $1.id } // last at top..
        assert(retArray.first?.blockNumber == blockNumber)
        assert(count == retArray.count) //all blocks are not pending?
        return retArray
    }
}
