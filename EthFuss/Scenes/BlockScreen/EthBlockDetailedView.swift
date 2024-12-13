//
//  EthBlockDetailedView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct EthBlockDetailedView: View {
    @ObservedObject var viewModel: EthBlockDetailedViewModel
    
    @ViewBuilder var contentView: some View {
        List {
            Section {
                VStack {
                    
                }
            }
            //.animation(.default, value: <#T##V#>)
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
