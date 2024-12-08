//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import Foundation


struct EthMethodParams<U> {
    let id: UInt64
    let version: JSONRPCVersionInfo
    let method: EthMethod
    let params: U
    
    init(id: UInt64,
         version: JSONRPCVersionInfo,
         method: EthMethod,
         params: U){
        self.id = id
        self.version = version
        self.method = method
        self.params = params
    }
}

extension EthMethodParams {
    init<K>(id: UInt64,
            version: JSONRPCVersionInfo,
            method: EthMethod) where U == [K] {
        self.init(id: id,
                  version: version,
                  method: method,
                  params: [K]())
    }
}

extension EthMethodParams: Encodable where U: Encodable {
    enum CodingKeys: CodingKey {
        case method
        case params
    }
    
    func encode(to encoder: Encoder) throws {
        
        try BaseJSONRPC(id: id,
                        version: version).encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(method.name, forKey: .method)
        try container.encode(params, forKey: .params)
    }
}

public enum BlockTag: RawRepresentable, Sendable {
    public enum Text: String, Sendable {
        case earliest
        case latest
        case pending
        case safe
        case finalized
    }
    
    public static let latest: Self = .text(.latest)
    
    case text(_ value: Text)
    case quantity(_ value: UInt64)
    
    public var rawValue: String {
        switch self {
        case .text(let text):
            return text.rawValue
        case .quantity(let value):
            return value.hexString()
        }
    }
    
    public init?(rawValue: String) {
        if let text = Text(rawValue: rawValue) {
            self = .text(text)
        } else if let value = try? rawValue.hexToUInt64() {
            self = .quantity(value)
        } else {
            return nil
        }
    }
}

enum EthMethod {
    var name: String {
        switch self {
        case .gossip(let method):
            return "eth_\(method.rawValue)"
        case .history(let method):
            return "eth_get\(method.rawValue.capitalizeFirstLetter())"
        }
    }
    
    enum Gossip: String {
        case blockNumber
        case blobBaseFee
        case accounts
    }
    
    enum History: String {
        case blockByNumber
    }
    
    case gossip(_ method: Gossip)
    case history(_ method: History)
}

struct EncodableItemWrapper: Encodable {
    let items: [EncodableValue]
}

enum EncodableValue: Encodable {
    case int(Int)
    case string(String)
    case bool(Bool)
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }
}
