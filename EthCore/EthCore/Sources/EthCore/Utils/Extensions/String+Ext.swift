//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 06/12/2024.
//

import Foundation

public extension String {
    func hexToUInt64(prefix prefixStr: String = "0x") throws -> UInt64? {
        let raw = self
        let cleanedHexString = raw.hasPrefix(prefixStr) ? String(raw.dropFirst(prefixStr.count)) : raw
        guard let value = UInt64(cleanedHexString, radix: 16) else {
            throw EthError.invalidResponse(raw.data(using: .utf8))
        }
        return value
    }
}

extension String {
    func capitalizeFirstLetter() -> Self {
        let text = self
        guard !text.isEmpty else {
            return text
        }
        
        return text.prefix(1).uppercased() + text.dropFirst()
    }
}
