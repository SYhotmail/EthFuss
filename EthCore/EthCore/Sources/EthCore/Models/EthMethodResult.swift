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

public struct EthTransactionObjectResult: Decodable, Sendable {
    // Common Fields
    public let hash: String             // Transaction hash
    public let nonce: String            // Transaction nonce
    public let blockHash: String?       // Hash of the block containing this transaction
    public let blockNumber: String?     // Block number (optional if pending)
    public let transactionIndex: String? // Index of the transaction in the block
    
    public let from: String             // Sender's address
    public let to: String?              // Recipient's address (nil for contract creation)
    public let value: String            // Value transferred in wei (String to avoid precision issues)
    public let gas: String              // Gas limit
    public let gasPrice: String         // Gas price in wei (String to avoid precision issues)
    
    // Optional Fields for Input and Signature
    public let input: String?            // Data payload (hex string)
    public let v: String?               // Recovery ID (part of the signature)
    public let r: String?               // ECDSA signature r value
    public let s: String?               // ECDSA signature s value
}


/*
 struct Block: Codable {
     let number: String // Hexadecimal string
     let hash: String?
     let parentHash: String
     let nonce: String
     let sha3Uncles: String
     let logsBloom: String
     let transactions: [Transaction] // Array of transactions (can be full or hashes depending on request)
     let transactionsRoot: String?
     let stateRoot: String?
     let miner: String?
     let difficulty: String?
     let totalDifficulty: String?
     let extraData: String?
     let size: String?
     let gasLimit: String?
     let gasUsed: String?
     let timestamp: String // Unix timestamp in hexadecimal format
     let uncles: [String] // Array of uncle block hashes
 }
 */

public struct EthBlockObjectResult: Decodable, Sendable {
    public let miner: String //20bytes.. - 42 characters...
    public let number: String?
    public let timestamp: String
    
    public enum TransactionInfoState: Decodable, Sendable {
        case raw(address: String)
        case object(_ object: EthTransactionObjectResult)
        
        public init(from decoder: any Decoder) throws {
            
            if let container = try? decoder.singleValueContainer(), let raw = try? container.decode(String.self) {
                self = .raw(address: raw)
            } else {
                let transactionObject = try EthTransactionObjectResult(from: decoder)
                self = .object(transactionObject)
            }
        }
    }
    
    public let transactions: [TransactionInfoState]
}
