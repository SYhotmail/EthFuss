//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import Foundation

public struct EthMethodResult<T> {
    /// jsonrpc
    let id: UInt64
    let version: JSONRPCVersionInfo
    let result: T

    func mapResult<V>(mapper: @escaping (T) throws -> V) throws -> EthMethodResult<V> {
        .init(id: id,
              version: version,
              result: try mapper(result))
    }
}

extension EthMethodResult: Sendable where T: Sendable {
}

extension EthMethodResult: Decodable where T: Decodable {
    enum CodingKeys: String, CodingKey {
        case result
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        
        let base = try BaseJSONRPC(from: decoder)
        
        self.init(id: base.id,
                  version: base.version,
                  result: try container.decode(T.self, forKey: .result))
    }
}
