import Testing
@testable import EthCore

@Test func blockNumberIdTest() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    
    let connector = EthConnector(ethConfig: .init(url: EthConfiguration.Test.sepolia.url))
    let id = UInt64(32)
    let result = try await connector.ethBlockNumber(id: id)
    #expect(id == result.id, "Wrong ids \(id) real \(result.id)")
}
