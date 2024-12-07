//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 07/12/2024.
//

import Foundation

// MARK: - EthereumError
public struct EthereumError: Error, Sendable {
    public let code: CodeState?
    public let message: String
    
    public enum CodeState: RawRepresentable, Sendable, Equatable {
        case parseError
        case internalError
        case invalidParams
        
        case methodNotFound
        case invalidRequest
        case serverError(_ inner: Int)
        
        var isServerError: Bool {
            if case .serverError = self {
                return true
            }
            return false
        }
        
        static let serverErrorCloseRange = ClosedRange(uncheckedBounds: (lower:-32099, upper:-32000))
        
        
        public var rawValue: Int {
            switch self {
            case .parseError:
                return -32700
            case .internalError:
                return -32603
            case .invalidParams:
                return -32602
            case .methodNotFound:
                return -32601
            case .invalidRequest:
                return -32600
            case let .serverError(inner):
                return inner
            }
        }
        
        public init?(rawValue: Int) {
            let fixedStates: [CodeState] = [.parseError,
                                            .internalError,
                                            .invalidParams,
                                            .methodNotFound,
                                            .invalidRequest]
            
            if let found = fixedStates.first(where: { $0.rawValue == rawValue }) {
                self = found
            } else if Self.serverErrorCloseRange.contains(rawValue) {
                self = .serverError(rawValue)
            } else {
                return nil
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            guard lhs.rawValue == rhs.rawValue else {
                return false
            }
            
            let isServer1 = lhs.isServerError == true
            let isServer2 = rhs.isServerError == true
            return isServer1 == isServer2
        }
    }
}

extension EthereumError: Decodable {
    enum CodingKeys: String, CodingKey {
        case message
        case code
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let codeRaw = try container.decodeIfPresent(Int.self, forKey: .code)
        let message = try container.decodeIfPresent(String.self, forKey: .message)
        
        self.init(code: codeRaw.flatMap { CodeState(rawValue: $0) },
                  message: message ?? "")
    }
}

public enum EthError: Error {
    case invalidResponse(_ data: Data?)
    case httpStatusCode(_ code: Int)
    case invalidId(expected: UInt64, real: UInt64?)
    case ethereumError(model: EthereumError)
    
    static func invalidResponse(from text: String) -> Self {
        let data = text.data(using: .utf8)
        return .invalidResponse(data)
    }
    
    var ethereumError: EthereumError? {
        if case .ethereumError(let innerError) = self {
            return innerError
        }
        return nil
    }
}
