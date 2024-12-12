//
//  ExploreMainScreenBlockRowView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//
import SwiftUI

struct ExploreMainScreenBlockRowView: View {
    @ObservedObject var viewModel: ExploreMainScreenViewModel.BlockViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "cube")
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(.gray.opacity(0.5))
                .clipShape(.rect(cornerSize: .init(width: 5, height: 5)))
            
            VStack {
                Button {
                    //action...
                } label: {
                    Text(viewModel.blockNumber.flatMap { String($0) } ?? "Pending")
                        .foregroundStyle(Color.primary)
                }

                Text(viewModel.timestamp)
                    .foregroundStyle(.gray)
                    .font(.footnote)
                    
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            if let transactionReward = viewModel.transactionReward {
                
                Text(transactionReward)
                    .font(.footnote.bold())
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 2) // Adds a blue border with rounded corners
                                )
                    //.border(, width: 1)
            }
            
        }
    }
}

