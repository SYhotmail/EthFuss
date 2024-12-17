//
//  ExploreMainScreenTransactionRowView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct ExploreMainScreenTransactionRowView: View {
    @ObservedObject var viewModel: ExploreMainScreenTransactionViewModel
    @State private var displayTransactionByHash = false
    @State private var displayFromReceiver = false
    @State private var displayToReceiver = false
    
    @ViewBuilder
    private func addressView(_ address: String, title: String, from: Bool) -> some View {
        HStack {
            Text(title)
            
            Button {
                let binding = from ? $displayFromReceiver : $displayToReceiver
                binding.wrappedValue = true
            } label: {
                Text(address)
                    .singleLongLineText()
                    .navigationDestination(isPresented: from ? $displayFromReceiver : $displayToReceiver) {
                        AddressScreenView(viewModel: viewModel.addressViewModel(address))
                    }
            }.foregroundStyle(.blue)
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "line.3.horizontal.button.angledtop.vertical.right")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .clipShape(.rect(cornerSize: .init(width: 5, height: 5)))
            
                if let timestamp = viewModel.timestampSubject.value {
                    Text(timestamp)
                        .font(.footnote)
                }
            }
            
            
            VStack {
                
            
                Button {
                    displayTransactionByHash = true
                } label: {
                    Text(viewModel.hash)
                        .singleLongLineText(truncationMode: .tail)
                        .navigationDestination(isPresented: $displayTransactionByHash) {
                            //TODO: provide..
                        }
                }.foregroundStyle(.blue)
                
                if let from = viewModel.from {
                    addressView(from, title: "From", from: true)
                }
                
                if let to = viewModel.to {
                    addressView(to, title: "To", from: false)
                }
            }
        } //hstack
    }
}

#Preview {
    ExploreMainScreenTransactionRowView(viewModel: .init(hash: "0x12424",
                                                         from: "0x142421412",
                                                         to: "0x432432",
                                                         value: "0x4323123",
                                                         gas: "0xsfds",
                                                         gasPrice: "0x32321"))
}
