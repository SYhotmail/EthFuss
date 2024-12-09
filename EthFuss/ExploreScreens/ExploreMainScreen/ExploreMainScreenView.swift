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
    func blockView(_ block: ExploreMainScreenViewModel.BlockItem) -> some View {
        HStack {
            Image(systemName: "cube.fill")
            
            VStack {
                Button {
                    //action...
                } label: {
                    Text(block.blockNumber.flatMap { "\($0)" } ?? "Pending")
                        .foregroundStyle(Color.primary)
                }

                Text(block.timestamp)
                    .font(.footnote)
                    
            }
            Spacer()
        }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                List {
                    Section {
                        ForEach(viewModel.latestBlocks) { block in
                            blockView(block)
                        }
                    } header: {
                        Text("Latest Blocks")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                    } footer: {
                        
                        Button {
                            
                        } label: {
                            HStack {
                               Text("View all blocks".uppercased())
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                                    .tint(.gray)
                            }
                        }
                    }
                    
                    Section {
                        ForEach(viewModel.latestBlocks) { block in
                            blockView(block)
                        }
                    } header: {
                        Text("Latest Transactions")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                    } footer: {
                        
                        Button {
                            
                        } label: {
                            HStack {
                               Text("View all transactions".uppercased())
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "arrow.right")
                                    .tint(.gray)
                            }
                        }

                    }
                    
                }.listStyle(.insetGrouped)
                    .navigationTitle("See result")
                
            }
        }
        
        
        /*NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            EthTopologhyView()
        } detail: {
            Text("Select an item")
        } */
    }

}

#Preview {
    ExploreMainScreenView(viewModel: .init(blockCount: 0,
                                           transactionCount: 0))
        .modelContainer(for: Item.self, inMemory: true)
}
