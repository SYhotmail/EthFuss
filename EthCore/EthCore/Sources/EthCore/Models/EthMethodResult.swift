//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import Foundation

public struct EthMethodResult<T> {
    public let id: UInt64
    public let version: JSONRPCVersionInfo
    public let result: T
    
    public func mapResult<U>(_ mapper: (T) throws -> U) throws -> EthMethodResult<U> {
        return .init(id: id,
                     version: version,
                     result: try mapper(result))
    }
}

struct EthMethodSwiftResult<T> {
    /// jsonrpc
    let id: UInt64
    let version: JSONRPCVersionInfo
    let result: Result<T, EthereumError>
    
    func methodResult() throws -> EthMethodResult<T> {
        switch result {
        case .success(let success):
            return .init(id: id,
                         version: version,
                         result: success)
        case .failure(let model):
            throw EthError.ethereumError(model: model)
        }
    }
}

extension EthMethodResult: Sendable where T: Sendable {
}

extension EthMethodSwiftResult: Decodable where T: Decodable {
    enum CodingKeys: String, CodingKey {
        case result
        case error
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        
        let base = try BaseJSONRPC(from: decoder)
        
        let result: Result<T, EthereumError>
        if let model = try? container.decode(T.self, forKey: .result) {
            result = .success(model)
        } else {
            let errorModel = try container.decode(EthereumError.self, forKey: .error)
            result = .failure(errorModel)
        }
        
        self.init(id: base.id,
                  version: base.version,
                  result: result)
    }
}


public struct EthBlockObjectResult: Decodable, Sendable {
    public let miner: String //20bytes.. - 42 characters...
    public let number: String?
}
