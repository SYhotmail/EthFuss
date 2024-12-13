//
//  ExploreMainScreenTransactionRowView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct ExploreMainScreenTransactionRowView: View {
    @ObservedObject var viewModel: ExploreMainScreenTransactionViewModel
    
    @ViewBuilder
    private func addressView(_ address: String, title: String) -> some View {
        HStack {
            Text(title)
            NavigationLink {
                AddressScreenView(viewModel: viewModel.addressViewModel(address))
            } label: {
                Text(address)
                    .singleLongLineText()
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.button.angledtop.vertical.right")
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .clipShape(.rect(cornerSize: .init(width: 5, height: 5)))
            
            
            
            VStack {
                NavigationLink(viewModel.hash) {
                    //TODO: hash here...
                    //AddressScreenView(viewModel: .init())
                }
                
                if let timestamp = viewModel.timestampSubject.value {
                    Text(timestamp)
                        .font(.footnote)
                }
            }
            
            VStack {
                if let from = viewModel.from {
                    addressView(from, title: "From")
                }
                
                if let to = viewModel.to {
                    addressView(to, title: "To")
                }
            }
            .padding(.horizontal, 20)
            
            
            
            /*if let weiValue = transaction.value.hexToUInt64() {
                
            }*/
            
        } //hstack
    }
}
