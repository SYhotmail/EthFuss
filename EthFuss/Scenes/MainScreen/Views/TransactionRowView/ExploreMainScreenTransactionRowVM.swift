//
//  ExploreMainScreenTransactionRowViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import Combine
import EthCore

typealias ExploreMainScreenTransactionViewModel = ExploreMainScreenViewModel.TransactionViewModel

extension ExploreMainScreenViewModel {
    
    struct TransactionViewModel: Identifiable {
        var id: String { hash }
        let hash: String
        let from: String?
        let to: String?
        let value: String //ETh...
        let gas: String
        let gasPrice: String
        let timestampSubject = CurrentValueSubject<String?, Never>(nil)
        
        nonmutating func setTimestampRaw(_ raw: String) {
            guard let unixTimestampRaw = try? raw.hexToUInt64() else {
                return
            }
            timestampSubject.value = Self.timeAgo(unixTimestamp: TimeInterval(unixTimestampRaw))
        }
        
        init(hash: String,
             from: String?,
             to: String?,
             value: String,
             gas: String,
             gasPrice: String) {
            self.hash = hash
            self.from = from
            self.to = to
            self.value = value
            self.gas = gas
            self.gasPrice = gasPrice
        }
        
        init?(transactionObject: EthTransactionObjectResult) {
            self.init(hash: transactionObject.hash,
                      from: transactionObject.from,
                      to: transactionObject.to,
                      value: transactionObject.value,
                      gas: transactionObject.gas,
                      gasPrice: transactionObject.gasPrice)
        }
        
        nonmutating func transactionFee() throws -> Decimal? {
            let gasHex = try gas.hexToUInt64()
            let gasPriceHex = try gasPrice.hexToUInt64()
            guard let gasHex, let gasPriceHex else {
                return nil
            }
            
            return Decimal(gasHex) * Decimal(gasPriceHex)
        }
        
        static func timeAgo(unixTimestamp: TimeInterval) -> String {
            let interval = Date().timeIntervalSince(Date(timeIntervalSince1970: unixTimestamp))
            
            let hours = Int(interval) / 3600
            let format: String
            let value: Int?
            if hours != 0 {
                value = hours
                format = "%d hours ago"
            } else {
                let minutes = (Int(interval) % 3600) / 60
                if minutes != 0 {
                    value = minutes
                    format = "%d mins ago"
                } else {
                    let seconds = Int(interval) % 60
                    if seconds != 0 {
                        value = seconds
                        format = "%d secs ago"
                    } else {
                        value = nil
                        format = "now"
                    }
                }
            }
            
            if let value {
                return .init(format: format, value) //TODO: support localization etc...
            } else {
                return format
            }
        }
    }
}
