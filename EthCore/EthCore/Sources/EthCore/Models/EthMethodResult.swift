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

// TODO: address can be validated as ^0x[0-9a-fA-F]{40}$

//TODO: hash 32 hex encoded bytes Pattern: ^0x[0-9a-f]{64}$

public struct EthBlockObjectResult: Decodable, Sendable {
    public let number: String?
    public let hash: String                 // The hash of the block
    public let parentHash: String           // The hash of the parent block
    public let nonce: String                // The block nonce (for PoW blocks)
    public let sha3Uncles: String           // Hash of the uncles in the block
    public let logsBloom: String?           // Bloom filter for logs (optional)
    public let transactionsRoot: String     // Root of the transaction trie
    public let stateRoot: String            // Root of the state trie
    public let receiptsRoot: String         // Root of the receipts trie
    public let miner: String                // Address of the miner
    public let difficulty: String           // Difficulty of the block
    public let totalDifficulty: String      // Total difficulty of the chain up to this block
    public let extraData: String?            // Extra data field of the block
    public let size: String                 // Size of the block in bytes
    public let gasLimit: String             // Maximum gas allowed in the block
    public let gasUsed: String              // Gas used by all transactions in the block
    public let timestamp: String            // Block timestamp (in seconds since epoch)
    public let uncles: [String]             // Array of uncle block hashes
    public let reward: String? //if available...
    public let baseFeePerGas: String
    
    public nonmutating func burnedFee() throws -> Decimal? {
        let gasHex = try gasUsed.hexToUInt64()
        let feePerGas = try baseFeePerGas.hexToUInt64()
        guard let gasHex, let feePerGas else {
            return nil
        }
        
        return Decimal(gasHex) * Decimal(feePerGas)
    }
    
    public enum TransactionInfoState: Decodable, Sendable {
        case raw(address: String)
        case object(_ object: EthTransactionObjectResult)
        
        public init(from decoder: any Decoder) throws {
            
            if let container = try? decoder.singleValueContainer(), let raw = try? container.decode(String.self) {
                self = .raw(address: raw)
            } else {
                do {
                    let transactionObject = try EthTransactionObjectResult(from: decoder)
                    self = .object(transactionObject)
                } catch {
                    throw error
                }
            }
        }
    }
    
    public let transactions: [TransactionInfoState]
}
