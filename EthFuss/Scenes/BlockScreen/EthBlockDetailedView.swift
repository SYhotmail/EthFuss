//
//  EthBlockDetailedView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct EthBlockDetailedView: View {
    @ObservedObject var viewModel: EthBlockDetailedViewModel
    
    @ViewBuilder
    private func rowView(_ info: EthBlockDetailedViewModel.TopSectionRowInfo) -> some View {
        switch info.type {
        case .blockHeight(let toolTip, let label, let number, let hasPrevious, let hasNext):
            
            HStack {
                Button(label, systemImage: "questionmark.circle") {
                    //TODO: show tooltip...
                }
                
                Spacer()
                
                Text(number)
                
                Image(systemName: "arrowshape.backward")
                    .padding(5)
                    .opacity(hasPrevious ? 1 : 0.5)
                    .onTapGesture(perform: viewModel.loadPrev)
                
                Image(systemName: "arrowshape.forward")
                    .padding(5)
                    .opacity(hasNext ? 1 : 0.5)
                    .onTapGesture(perform: viewModel.loadNext)
                
            }
        case .difficulty(let toolTip, let label, let number):
            HStack {
                Button(label, systemImage: "questionmark.circle") {
                    //TODO: show tooltip...
                }
                
                Spacer()
                
                Text(number)
            }
        }
    }
    
    @ViewBuilder var contentView: some View {
        List {
            Section {
                VStack(spacing: 0) {
                    ForEach(viewModel.topSectionRows) {
                        rowView($0)
                    }
                }
            }
            .transition(.move(edge: .leading))
            .animation(.default, value: viewModel.isLoading)
        }.listStyle(.insetGrouped)
    }
    
    @ViewBuilder var bodyCore: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.gray)
        } else {
            contentView
                .transition(.move(edge: .leading))
        }
    }
    
    var body: some View {
        bodyCore
            .navigationTitle(viewModel.title ?? "")
    }
}
