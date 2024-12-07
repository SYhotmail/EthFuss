// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct EthConnector: Sendable {
    /// configuration: configuration of the network...
    let ethConfig: EthConfiguration
    
    let network: URLSession
    let postRequest: URLRequest
    
    public init(ethConfig: EthConfiguration = .init(url: EthConfiguration.Test.sepolia.url), config: URLSessionConfiguration? = nil) {
        self.ethConfig = ethConfig
        let url = ethConfig.url
        
        var postRequest = URLRequest(url: url)
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.postRequest = postRequest
        self.network = .init(configuration: config ?? .default)
    }
    
    private func ethMethodRun(id idCore: UInt64? = nil, method: EthMethod) async throws -> EthMethodResult<UInt64> {
        let id = idCore ?? .random(in: UInt64.min...UInt64.max)
        let params = EthMethodParams<Int>(id: id,
                                          version: ethConfig.jsonRPCVersion,
                                          method: method)
        let encoder = JSONEncoder()
        let data = try encoder.encode(params)
        
        var request = postRequest
        request.httpBody = data
        
        let tuple = try await network.data(for: request)
        
        let responseData = tuple.0
        let response = tuple.1
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EthError.invalidResponse(responseData)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw EthError.httpStatusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(EthMethodSwiftResult<String>.self, from: responseData)
        guard result.id == id else {
            throw EthError.invalidId(expected: id, real: result.id)
        }
        
        let rawResult = try result.methodResult()
        
        return try rawResult.mapResult { text in 
            guard let value = try text.hexToUInt64() else {
                throw EthError.invalidResponse(from: text)
            }
            return value
        }
    }
    
    //eth_blockNumber
    public func ethBlockNumber(id idCore: UInt64? = nil) async throws -> EthMethodResult<UInt64> {
        try await ethMethodRun(id: idCore, method: .gossip(.blockNumber))
    }
    
    public func ethBlobBaseFee(id idCore: UInt64? = nil) async throws -> EthMethodResult<UInt64> {
        try await ethMethodRun(id: idCore, method: .gossip(.blobBaseFee))
    }
}

public struct EthConfiguration: Sendable {
    public enum Test {
        case sepolia
        
        var host: String {
            switch self {
            case .sepolia:
                return "rpc.sepolia.org"
            }
        }
        
        public var url: URL! {
            var components = URLComponents()
            components.scheme = "https"
            components.host = host
            return components.url
        }
    }
    
    /// url of the network.
    let url: URL
    let jsonRPCVersion: JSONRPCVersionInfo
    
    public init(url: URL,
                jsonRPCVersion: JSONRPCVersionInfo = .init(major: 2,
                                                           minor: 0)) {
        self.url = url
        self.jsonRPCVersion = jsonRPCVersion
    }
}
