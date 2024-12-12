//
//  ContentView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 01/12/2024.
//

import SwiftUI
import SwiftData

struct ExploreMainScreenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @ObservedObject var viewModel: ExploreMainScreenViewModel
    
    @ViewBuilder
    func transactionView(_ transaction: ExploreMainScreenViewModel.TransactionViewModel) -> some View {
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
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                List {
                    Section {
                        ForEach(viewModel.latestBlocks) { blockVM in
                            ExploreMainScreenBlockRowView(viewModel: blockVM)
                        }
                    } header: {
                        Text("Latest Blocks")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.black)
                    } footer: {
                        
                        Button {
                            
                        } label: {
                            HStack {
                               Text("View all blocks".uppercased())
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                                    .tint(.gray)
                            }
                        }
                    }
                    
                    Section {
                        ForEach(viewModel.transactions) { transaction in
                            transactionView(transaction)
                        }
                    } header: {
                        Text("Latest Transactions")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.black)
                    } footer: {
                        
                        Button {
                            
                        } label: {
                            HStack {
                               Text("View all transactions".uppercased())
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                                    .tint(.gray)
                            }
                        }
                    }
                }.listStyle(.insetGrouped)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { // <2>
                        ToolbarItem(placement: .principal) {
                            Text(viewModel.title ?? "")
                                .font(.headline)
                        }
                        
                    }
                    //.navigationTitle(viewModel.title ?? "")
                
            }
        }
    }

}

#Preview {
    ExploreMainScreenView(viewModel: .init(blockCount: 0,
                                           transactionCount: 0))
        .modelContainer(for: Item.self, inMemory: true)
}
