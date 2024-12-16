//
//  EthBlockDetailedViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import Foundation
import EthCore
import Combine

final class EthBlockDetailedViewModel: ObservableObject {
    private(set)var blockHash: String!
    private(set)var blockNumber: UInt64!
    private let connector = EthConnector()
    
    private var task: Task<EthBlockObjectResult, any Error>?
    private var disposeBag = Set<AnyCancellable>()
    
    @Published var isLoading = false
    let ethObjectSubject = CurrentValueSubject<EthBlockObjectResult?, Never>(nil)
    @Published var topSectionRows = [TopSectionRowInfo]()
    
    struct TopSectionRowInfo: Identifiable {
        var id: String { type.label }
        let type: TopSectionRowType
    }
        
    enum TopSectionRowType {
        case blockHeight(toolTip: String, label: String, number: String, hasPrevious: Bool, hasNext: Bool)
        case difficulty(toolTip: String, label: String, number: String)
        
        var toolTip: String {
            switch self {
            case let .blockHeight(toolTip, _, _, _, _):
                return toolTip
            case let .difficulty(toolTip, _, _):
                return toolTip
            }
        }
        
        var label: String {
            switch self {
            case let .blockHeight(_, label, _, _, _):
                return label
            case let .difficulty(_, label, _):
                return label
            }
        }
    }
    
    private var lastBlockNumber: UInt64?
    
    init(blockHash: String, blockNumber: UInt64?) {
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.lastBlockNumber = blockNumber
        
        bind()
        
        scheduleBlockLoad(blockNumber: blockNumber, blockHash: blockHash)
    }
    
    private func hasNext() -> Bool {
        blockNumber != lastBlockNumber // caching value...
    }
    
    private func scheduleBlockLoad(positive: Bool) {
        scheduleBlockLoad(blockNumber: blockNumber.flatMap { positive ? $0 + 1 : $0 - 1 },
                          blockHash: nil)
    }
    
    func loadNext() {
        guard hasNext() else {
            return
        }
        
        scheduleBlockLoad(positive: true)
    }
    
    func loadPrev() {
        scheduleBlockLoad(positive: false)
    }
    
    private func bind() {
        ethObjectSubject.dropFirst()
            .map { [unowned self] result -> [TopSectionRowInfo] in
                var info = [TopSectionRowInfo]()
                if let number = result?.number {
                    info.append(.init(type: .blockHeight(toolTip: "Also known as a block number",
                                                         label: "Block Height:",
                                                         number: number,
                                                         hasPrevious: true,
                                                         hasNext: self.hasNext()) ))
                }
                
                if let totalDifficulty = result?.totalDifficulty {
                    info.append(.init(type: .difficulty(toolTip: "Total difficulty of the chain",
                                                        label: "Total Difficulty:",
                                                        number: totalDifficulty) ))
                }
                
                return info
            }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] topSectionRows in
                self.topSectionRows = topSectionRows
            }.store(in: &disposeBag)
    }
    
    private func loadBlock(blockNumber: UInt64?, blockHash: String?) async throws -> EthMethodResult<EthBlockObjectResult> {
        if let blockNumber {
            return try await self.connector.ethBlockByNumber(tag: .quantity(blockNumber), full: true)
        } else if let blockHash {
            return try await self.connector.ethBlockByHash(hash: blockHash, full: true)
        } else {
            assertionFailure("Can't be here!")
            throw NSError(domain: "ethfuss.error", code: .min)
        }
    }
    
    @MainActor
    private func setIsLoadingUI(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    private func scheduleBlockLoad(blockNumber: UInt64?, blockHash: String?) {
        task?.cancel()
        task = Task {
            await self.setIsLoadingUI(true)
            do {
                try Task.checkCancellation()
                let result = try await self.loadBlock(blockNumber: blockNumber,
                                                      blockHash: blockHash)
                self.blockNumber = blockNumber
                self.blockHash = blockHash
                let value = result.result
                self.ethObjectSubject.value = value
                await self.setIsLoadingUI(false)
                return value
            } catch {
                await self.setIsLoadingUI(false)
                //TODO: key not found therefore last is a prev. one...
                throw error
            }
        }
    }
    
    deinit {
        disposeBag.forEach { $0.cancel() }
    }
    
    var title: String? {
        guard let blockNumber else {
            return nil
        }
        return "Block # \(String(blockNumber))"
    }
}
