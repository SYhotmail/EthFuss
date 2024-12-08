//
//  ExploreMainScreenViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 08/12/2024.
//

import Foundation
import EthCore

final class ExploreMainScreenViewModel: ObservableObject {
    
    struct BlockItem: Identifiable {
        let id: String
        let blockNumber: UInt64?
        
        init(blockNumber: UInt64?) {
            self.blockNumber = blockNumber
            self.id = blockNumber?.hexString() ?? UUID().uuidString
        }
    }
    
    @Published var latestBlocks = [BlockItem]()
    
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
                Task { @MainActor in
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
    
    func receiveBlocks(number: Int) async throws -> [BlockItem] {
        guard number > 0 else {
            return []
        }
        let blockNumber = try await connector.ethBlockNumber().result
        
        //var items = [BlockItem?](repeating: nil, count: number)
        
        let items = try await withThrowingTaskGroup(of: EthBlockObjectResult.self) { group in
            for i in 0..<number {
                _ = group.addTaskUnlessCancelled {
                    try await self.connector.ethBlockByNumber(tag: .quantity(blockNumber - UInt64(i)) ,full: false).result
                }
            }
            var results = [EthBlockObjectResult]()
            
            guard !group.isEmpty, !group.isCancelled else {
                return results
            }
            
            /*while let result = try await group.next() {
                ///        collected += value
                ///     }
                results.append(result)
            }*/
            
            for try await result in group {
                results.append(result)
            }
            return results
        }
        
        //withTaskGroup(of: <#T##Sendable.Type#>, returning: <#T##GroupResult.Type#>, body: <#T##(inout TaskGroup<Sendable>) async -> GroupResult#>)
        
        return items.map { BlockItem(blockNumber: try? $0.number?.hexToUInt64()) }.sorted { $0.id > $1.id } // last at top..
    }
}
