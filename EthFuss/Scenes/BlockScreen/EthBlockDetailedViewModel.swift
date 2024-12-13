//
//  EthBlockDetailedViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import Foundation
import EthCore

final class EthBlockDetailedViewModel: ObservableObject {
    let blockObject: EthBlockObjectResult
    init(blockObject: EthBlockObjectResult) {
        self.blockObject = blockObject
    }
    
    var title: String? {
        guard let number = blockObject.number, let hex = try? number.hexToUInt64() else {
            return nil
        }
        return "Block # \(String(hex))"
    }
}
