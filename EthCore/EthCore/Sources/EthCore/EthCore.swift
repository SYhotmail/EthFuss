// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct EthConnector: Sendable {
    /// configuration: configuration of the network...
    public let ethConfig: EthConfiguration
    
    let network: URLSession
    let postRequest: URLRequest
    
    public init(ethConfig: EthConfiguration = .init(netType: .test(.sepolia)), config: URLSessionConfiguration? = nil) {
        self.ethConfig = ethConfig
        let url = ethConfig.netType.url
        
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
        
        let statusCode = httpResponse.statusCode
        guard statusCode == 200 else {
            if statusCode == 503 {
                //retry ...
                debugPrint("!!! 503  \(httpResponse.allHeaderFields)")
            }
            throw EthError.httpStatusCode(statusCode)
        }
        
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(EthMethodSwiftResult<Result>.self, from: responseData)
            guard result.id == id else {
                throw EthError.invalidId(expected: id, real: result.id)
            }
            return try result.methodResult()
            
        } catch {
            
            print("!!! can't handle \(String(data: responseData, encoding: .utf8) ?? "nil")")
            throw error
        }
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
    
    private func ethBlockByNumberOrHash(id idCore: UInt64? = nil,
                                        tag: BlockTag!,
                                        hash: String!,
                                        full: Bool = false) async throws -> EthMethodResult<EthBlockObjectResult> {
        assert((tag != nil && hash == nil) || (tag == nil && hash != nil) )
        let paramStr: String! = tag?.rawValue ?? hash
        assert(paramStr != nil)
        return try await ethMethodParams(id: idCore,
                                         method: .history(tag != nil ? .blockByNumber : .blockByHash),
                                         params: [EncodableValue](arrayLiteral: .string(paramStr),
                                                                                .bool(full)))
    }
    
    public func ethBlockByNumber(id: UInt64? = nil,
                                 tag: BlockTag = .latest,
                                 full: Bool = false) async throws -> EthMethodResult<EthBlockObjectResult> {
        try await ethBlockByNumberOrHash(id: id,
                                         tag: tag,
                                         hash: nil,
                                         full: full)
    }
    
    //TODO: hash has containts 32 bytes, check it...
    public func ethBlockByHash(id: UInt64? = nil,
                               hash: String,
                               full: Bool = false) async throws -> EthMethodResult<EthBlockObjectResult> {
        try await ethBlockByNumberOrHash(id: id,
                                         tag: nil,
                                         hash: hash,
                                         full: full)
    }
    
    public func ethAccounts(id idCore: UInt64? = nil) async throws -> EthMethodResult<[String]> {
        try await ethMethodParams(id: idCore, method: .gossip(.accounts), params: [UInt64]())
    }
}

public struct EthConfiguration: Sendable {
    public enum Test: Sendable {
        case sepolia
        
        var host: String {
            switch self {
            case .sepolia:
                return "rpc.sepolia.org"
            }
        }
        
        var name: String? {
            switch self {
            case .sepolia:
                return "Sepolia Testnet"
            }
        }
        
        public var url: URL! {
            var components = URLComponents()
            components.scheme = "https"
            components.host = host
            return components.url
        }
    }
    
    public enum NetType: Sendable {
        case mainnet(url: URL)
        case test(_ raw: Test)
        
        var url: URL {
            switch self {
            case .mainnet(let url):
                return url
            case .test(let raw):
                return raw.url
            }
        }
        
        public var name: String? {
            if case .test(let test) = self {
                return test.name
            }
            return nil
        }
    }
    
    /// net type.
    public let netType: NetType
    
    let jsonRPCVersion: JSONRPCVersionInfo
    
    public init(netType: NetType,
                jsonRPCVersion: JSONRPCVersionInfo = .init(major: 2,
                                                           minor: 0)) {
        self.netType = netType
        self.jsonRPCVersion = jsonRPCVersion
    }
}
