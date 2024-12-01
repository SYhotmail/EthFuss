//
//  File.swift
//  EthCore
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import Foundation

// MARK: - BaseJSONRPC
struct BaseJSONRPC {
    let id: UInt64
    let version: JSONRPCVersionInfo
    
    init(id: UInt64,
         version: JSONRPCVersionInfo) {
        self.id = id
        self.version = version
    }
}

// MARK: - BaseJSONRPC.Codable
extension BaseJSONRPC: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case version = "jsonrpc"
    }
    
    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(JSONRPCVersionInfo.self, forKey: .version) // major - minor...
        let id = try container.decode(UInt64.self, forKey: .id)
        self.init(id: id,
                  version: version)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(version, forKey: .version)
    }
}
