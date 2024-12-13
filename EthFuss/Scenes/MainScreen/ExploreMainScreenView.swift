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
    
    //TODO: here...
    @ViewBuilder
    func transactionView(_ transaction: ExploreMainScreenTransactionViewModel) -> some View {
        ExploreMainScreenTransactionRowView(viewModel: transaction)
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
                }
                //.tint(.clear)
                .listStyle(.insetGrouped)
                .selectionDisabled()
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
