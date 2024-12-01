// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

struct EthConnector {
    /// configuration: configuration of the network...
    let ethConfig: EthConfiguration
    
    let network: URLSession
    let postRequest: URLRequest
    
    init(ethConfig: EthConfiguration, config: URLSessionConfiguration? = nil) {
        self.ethConfig = ethConfig
        let url = ethConfig.url
        
        var postRequest = URLRequest(url: url)
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.postRequest = postRequest
        self.network = .init(configuration: config ?? .default)
    }
    
    //eth_blockNumber
    func ethBlockNumber(id idCore: UInt64? = nil) async throws -> EthMethodResult<UInt64> {
        let id = idCore ?? .random(in: UInt64.min...UInt64.max)
        let params = EthMethodParams<Int>(id: id,
                                          version: ethConfig.jsonRPCVersion,
                                          method: .gossip(.blockNumber))
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
        let result = try decoder.decode(EthMethodResult<String>.self, from: responseData)
        
        guard result.id == id else {
            throw EthError.invalidId(expected: id, real: result.id)
        }
        
        return try result.mapResult { raw in
            let prefixStr = "0x"
            let cleanedHexString = raw.hasPrefix(prefixStr) ? String(raw.dropFirst(prefixStr.count)) : raw
            
            guard let value = UInt64(cleanedHexString, radix: 16) else {
                throw EthError.invalidResponse(raw.data(using: .utf8))
            }
            return value
        }
    }
}

enum EthError: Error {
    case invalidResponse(_ data: Data?)
    case httpStatusCode(_ code: Int)
    case invalidId(expected: UInt64, real: UInt64?)
    
    static func invalidResponse(from text: String) -> Self {
        let data = text.data(using: .utf8)
        return .invalidResponse(data)
    }
}

struct EthConfiguration {
    enum Test {
        case sepolia
        
        var host: String {
            switch self {
            case .sepolia:
                return "rpc.sepolia.org"
            }
        }
        
        var url: URL! {
            var components = URLComponents()
            components.scheme = "https"
            components.host = host
            return components.url
        }
    }
    
    /// url of the network.
    let url: URL
    var jsonRPCVersion = JSONRPCVersionInfo(major: 2, minor: 0)
}
