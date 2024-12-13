//
//  ExploreMainScreenTransactionRowView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct ExploreMainScreenTransactionRowView: View {
    @ObservedObject viewModel: 
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.button.angledtop.vertical.right")
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .clipShape(.rect(cornerSize: .init(width: 5, height: 5)))
            
            
            
            VStack {
                NavigationLink(transaction.hash) {
                    //TODO: hash here...
                    AddressScreenView(viewModel: .init())
                }
                
                if let timestamp = transaction.timestampSubject.value {
                    Text(timestamp)
                        .font(.footnote)
                }
            }
            
            VStack {
                if let from = transaction.from {
                    HStack {
                        Text("From")
                        NavigationLink {
                            AddressScreenView(viewModel: .init())
                        } label: {
                            Text(from)
                                .singleLongLineText()
                        }
                    }
                }
                
                if let to = transaction.to {
                    HStack {
                        Text("To")
                        NavigationLink {
                            AddressScreenView(viewModel: .init())
                        } label: {
                            Text(to)
                                .singleLongLineText()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            
            
            /*if let weiValue = transaction.value.hexToUInt64() {
                
            }*/
            
        } //hstack
    }
}
