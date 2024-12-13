//
//  TransactionScreenView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 11/12/2024.
//

import SwiftUI

struct AddressScreenView: View {
    @ObservedObject var viewModel: AddressScreenViewModel
    
    init(viewModel: AddressScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text("Check")
            .onAppear {
                debugPrint("!!! Appeared")
            }
    }
}
