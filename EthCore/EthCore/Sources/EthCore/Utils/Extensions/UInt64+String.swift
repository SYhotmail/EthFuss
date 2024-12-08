//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 07/12/2024.
//

import Foundation

public extension UInt64 {
    func hexString(prefix prefixStr: String = "0x") -> String {
        prefixStr + String(self, radix: 16)
    }
}
