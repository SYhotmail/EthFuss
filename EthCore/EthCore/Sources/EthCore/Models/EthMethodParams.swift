//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import Foundation

struct EthMethodParams<T> {
    let id: UInt64
    let version: JSONRPCVersionInfo
    let method: EthMethod
    let params: [T]
    
    init(id: UInt64,
         version: JSONRPCVersionInfo,
         method: EthMethod,
         params: [T] = []) {
        self.id = id
        self.version = version
        self.method = method
        self.params = params
    }
}

extension EthMethodParams: Encodable where T: Encodable {
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

enum EthMethod {
    var name: String {
        switch self {
        case .gossip(let method):
            return method.rawValue
        }
    }
    
    enum Gossip: String {
        case blockNumber = "eth_blockNumber"
    }
    
    case gossip(_ method: Gossip)
}
