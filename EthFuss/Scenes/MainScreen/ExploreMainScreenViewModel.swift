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
    
    @Published var latestBlocks = [BlockViewModel]()
    @Published var transactions = [TransactionViewModel]()
    @Published var isLoading = false
    
    let connector = EthConnector()
    let blockCount: Int
    let transactionCount: Int
    
    var title: String? {
        let netType = connector.ethConfig.netType
        return netType.name.flatMap { "\($0) Explorer" }
    }
    
    init(blockCount: Int = 5, transactionCount: Int = 5) {
        self.blockCount = blockCount
        self.transactionCount = transactionCount
        
        defineCoreTask()
    }
    
    private func defineCoreTask() {
        isLoading = true
        Task {
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
                    self.isLoading = false
                }
            }
            catch {
                self.isLoading = false
                debugPrint("!!! Error \(error)")
            }
        }
    }
    
    func receiveBlocks(number: Int) async throws -> [BlockViewModel] {
        guard number > 0 else {
            return []
        }
        let blockNumber = try await connector.ethBlockNumber().result
        
        let items = try await withThrowingTaskGroup(of: EthBlockObjectResult.self) { group in
            for i in 0..<number {
                _ = group.addTaskUnlessCancelled {
                    try await self.connector.ethBlockByNumber(tag: .quantity(blockNumber - UInt64(i)) ,full: true).result
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
        let retArray = items.compactMap { BlockViewModel(blockObject: $0) }.sorted { $0.unixTimestamp > $1.unixTimestamp } // last at top..
        assert(retArray.first?.blockNumber == blockNumber)
        assert(count == retArray.count) //all blocks are not pending?
        return retArray
    }
}
