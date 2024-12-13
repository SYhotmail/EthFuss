//
//  ExploreMainScreenBlockRowView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//
import SwiftUI

struct ExploreMainScreenBlockRowView: View {
    @ObservedObject var viewModel: ExploreMainScreenRowViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "cube")
                .symbolEffect(.bounce, value: 1)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(.gray.opacity(0.3))
                .clipShape(.rect(cornerSize: .init(width: 10, height: 10)))
                .layoutPriority(1)
            
            VStack {
                if let blockObject = viewModel.blockObject {
                    NavigationLink {
                        EthBlockDetailedView(viewModel: .init(blockObject: blockObject))
                    } label: {
                        Text(viewModel.blockNumber.flatMap { String($0) } ?? "Pending")
                            .foregroundStyle(Color.blue)
                    }
                }

                Text(viewModel.timestamp)
                    .foregroundStyle(.gray)
                    .font(.footnote)
                    
            }
            .padding(.horizontal, 20)
            
            VStack {
                HStack {
                    Text("Fee Recipient")
                    NavigationLink {
                        AddressScreenView(viewModel: .init())
                    } label: {
                        Text(viewModel.miner)
                            .singleLongLineText()
                            .foregroundStyle(Color.blue)
                    }

                    /*Button(action: viewModel.onRecipientPressed) {
                        Text(viewModel.miner)
                            .singleLongLineText()
                    }*/
                }
                
                //viewModel.transactions.
            }
            
            Spacer()
            
            if let transactionReward = viewModel.transactionReward {
                
                Text(transactionReward)
                    .font(.footnote.bold())
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 1) // Adds a blue border with rounded corners
                                )
                    //.border(, width: 1)
            }
            
        }
    }
}

