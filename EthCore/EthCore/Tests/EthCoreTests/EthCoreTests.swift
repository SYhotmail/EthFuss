import Testing
@testable import EthCore

private func sepoliaTestConnector() -> EthConnector {
    .init(ethConfig: .init(url: EthConfiguration.Test.sepolia.url))
}

@Test func blockNumberIdTest() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    
    let connector = sepoliaTestConnector()
    let id = UInt64(32)
    let result = try await connector.ethBlockNumber(id: id)
    #expect(id == result.id, "Wrong ids \(id) real \(result.id)")
}

@Test func blockBaseFeeTest() async throws {
    let connector = sepoliaTestConnector()
    
    do {
        _ = try await connector.ethBlobBaseFee()
    } catch {
        if case EthError.ethereumError(model: let model) = error, model.code == .methodNotFound {
            return
        }
    }
    
    throw EthError.invalidResponse(nil)
}
