//
//  EthBlockDetailedViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import Foundation
import EthCore

final class EthBlockDetailedViewModel: ObservableObject {
    private(set)var blockHash: String
    private(set)var blockNumber: UInt64?
    private let connector = EthConnector()
    
    @Published var isLoading = false
    @Published var ethObject: EthBlockObjectResult?
    @Published var topSectionRows = [TopSectionRowInfo]()
    
    struct TopSectionRowInfo {
        let type: TopSectionRowType
        let data: Any
    }
        
    enum TopSectionRowType {
        case blockHeight
        case timestamp
    }
    
    init(blockHash: String, blockNumber: UInt64?) {
        self.blockHash = blockHash
        self.blockNumber = blockNumber
    }
    
    //TODO: load content...
    
    
    
    
    var title: String? {
        guard let blockNumber else {
            return nil
        }
        return "Block # \(String(blockNumber))"
    }
}
