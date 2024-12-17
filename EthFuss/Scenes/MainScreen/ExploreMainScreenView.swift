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
    
    @State var showUnderConstruction = false
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .progressViewStyle(.circular)
        } else {
            bodyCore
                .alert("Not implemented", isPresented: $showUnderConstruction) {
                    Button("OK",
                           role: .cancel) {}
                }
                .alert(viewModel.alertErrorText ?? "",
                       isPresented: $viewModel.presentAlert, actions: {
                    
                    Button("OK",
                           role: .cancel,
                           action: viewModel.onAlertPressed)
                })
        }
    }
    
    @ViewBuilder var bodyCore: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        ForEach(viewModel.latestBlocks) { blockVM in
                            ExploreMainScreenBlockRowView(viewModel: blockVM)
                                .selectionDisabled()
                        }
                    } header: {
                        Text("Latest Blocks")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.black)
                    } footer: {
                        Button {
                            showUnderConstruction = true
                        } label: {
                            HStack {
                               Text("View all blocks".uppercased())
                                    .padding(.horizontal, 2)
                                    .padding(.vertical, 5)
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                                    .tint(.gray)
                            }.contentMargins(5)
                        }
                    }
                    
                    Section {
                        ForEach(viewModel.transactions) { transaction in
                            ExploreMainScreenTransactionRowView(viewModel: transaction)
                                .selectionDisabled()
                        }
                    } header: {
                        Text("Latest Transactions")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.black)
                    } footer: {
                        
                        Button {
                            showUnderConstruction = true
                        } label: {
                            HStack {
                               Text("View all transactions".uppercased())
                                    .padding(.horizontal, 2)
                                    .padding(.vertical, 5)
                                    .font(.body.weight(.bold))
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                                    .tint(.gray)
                            }.contentMargins(5)
                        }
                    }
                }
                //.tint(.clear)
                .listStyle(.insetGrouped)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar { // <2>
                        ToolbarItem(placement: .principal) {
                            Text(viewModel.title ?? "")
                                .font(.headline)
                        }
                        
                    }
            }
        }
    }
}

#Preview {
    ExploreMainScreenView(viewModel: .init(blockCount: 0,
                                           transactionCount: 0))
        .modelContainer(for: Item.self, inMemory: true)
}
