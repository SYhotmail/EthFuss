//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 06/12/2024.
//

import Foundation

extension String {
    func hexToUInt64() throws -> UInt64? {
        let raw = self
        let prefixStr = "0x"
        let cleanedHexString = raw.hasPrefix(prefixStr) ? String(raw.dropFirst(prefixStr.count)) : raw
        
        guard let value = UInt64(cleanedHexString, radix: 16) else {
            throw EthError.invalidResponse(raw.data(using: .utf8))
        }
        return value
    }
}