//
//  AddressScreenViewModel.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//

import SwiftUI
import Combine

final class AddressScreenViewModel: ObservableObject {
    let address: String
    
    init(address: String) {
        self.address = address
    }
}
