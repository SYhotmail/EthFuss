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
    
    private func ethMethodParams<Params: Encodable, Result: Decodable>(id idCore: UInt64? = nil, method: EthMethod, params innerParams: Params) async throws -> EthMethodResult<Result> {
        let id = idCore ?? .random(in: UInt64.min...UInt64.max)
        let params = EthMethodParams(id: id,
                                     version: ethConfig.jsonRPCVersion,
                                     method: method,
                                     params: innerParams)
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
        let result = try decoder.decode(EthMethodSwiftResult<Result>.self, from: responseData)
        guard result.id == id else {
            throw EthError.invalidId(expected: id, real: result.id)
        }
        
        return try result.methodResult()
    }
    
    private func ethMethodRun(id idCore: UInt64? = nil, method: EthMethod) async throws -> EthMethodResult<UInt64> {
        let rawResult: EthMethodResult<String> = try await ethMethodParams(id: idCore, method: method, params: [UInt64]())
        
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
    
    public func ethBlockByNumber(id idCore: UInt64? = nil, tag: BlockTag = .latest, full: Bool = false) async throws -> EthMethodResult<EthBlockObjectResult> {
        //TODO: change here...
        try await ethMethodParams(id: idCore,
                                  method: .history(.blockByNumber),
                                  params: [EncodableValue](arrayLiteral: .string(tag.rawValue),
                                                                        .bool(full)))
    }
    
    public func ethAccounts(id idCore: UInt64? = nil) async throws -> EthMethodResult<[String]> {
        try await ethMethodParams(id: idCore, method: .gossip(.accounts), params: [UInt64]())
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
