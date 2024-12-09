//
//  ExploreMainScreenViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 08/12/2024.
//

import Foundation
import EthCore

final class ExploreMainScreenViewModel: ObservableObject {
    
    enum BlockState {
        case pending
        case mined
    }
    
    struct BlockItem: Identifiable {
        let id: String
        let blockNumber: UInt64?
        let timestamp: String
        let blockState: BlockState
        
        init(blockNumber: UInt64?,
             unixTimestamp: TimeInterval) {
            self.blockNumber = blockNumber
            self.id = blockNumber?.hexString() ?? UUID().uuidString
            
            blockState = blockNumber != 0 ? .mined : .pending
            
            let interval = Date(timeIntervalSince1970: unixTimestamp).timeIntervalSinceNow
            assert(interval <= 0)
            timestamp = String(format: "%0.f mins ago", abs(interval/60)) //TODO: support localization etc...
        }
        
        init?(blockObject: EthBlockObjectResult) {
            guard let unixTimestampRaw = try? blockObject.timestamp.hexToUInt64() else {
                return nil
            }
            self.init(blockNumber: try? blockObject.number?.hexToUInt64(),
                      unixTimestamp: TimeInterval(unixTimestampRaw))
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
                    try await self.connector.ethBlockByNumber(tag: .quantity(blockNumber - UInt64(i)) ,full: i == 0 && false).result
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
        let retArray = items.compactMap { BlockItem(blockObject: $0) }.sorted { $0.id > $1.id } // last at top..
        assert(count == retArray.count) //all blocks are not pending?
        return retArray
    }
}
