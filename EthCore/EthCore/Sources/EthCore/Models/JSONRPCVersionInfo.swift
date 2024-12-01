//
//  JSONRPCVersionInfo.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import Foundation

public struct JSONRPCVersionInfo: Sendable {
    
    let major: UInt
    let minor: UInt
    let bugFixRelease: UInt?
    let buildNumber: UInt?
    
    public init(major: UInt, minor: UInt = 0, bugFixRelease: UInt? = nil, buildNumber: UInt? = nil) {
        self.major = major
        self.minor = minor
        self.bugFixRelease = bugFixRelease
        self.buildNumber = buildNumber
    }
    
}
 
extension JSONRPCVersionInfo: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        
        let parts = raw.components(separatedBy: ".")
        let count = parts.count
        let minCount = 2
        let maxCount = minCount + 2
        
        guard count >= minCount, count <= maxCount else {
            throw EthError.invalidResponse(from: raw)
        }
        
        let values = parts.compactMap { UInt($0) }
        guard values.count == count else {
            throw EthError.invalidResponse(from: raw)
        }
        
        self.init(major: values[0],
                  minor: values[1],
                  bugFixRelease: values.count > minCount ? values[minCount] : nil,
                  buildNumber: values.count == maxCount ? values[maxCount - 1] : nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        let parts = [major as UInt?,
                     minor as UInt?,
                     bugFixRelease,
                     buildNumber].compactMap { $0 }
        
        let value = parts.map { "\($0)" }.joined(separator: ".")
        try container.encode(value)
    }
}
