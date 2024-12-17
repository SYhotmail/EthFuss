//
//  ExploreMainScreenBlockRowView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 12/12/2024.
//
import SwiftUI

struct ExploreMainScreenBlockRowView: View {
    @ObservedObject var viewModel: ExploreMainScreenRowViewModel
    @State var activateLinkBlock = false
    @State var activateLinkRecipient = false
    var body: some View {
        HStack {
            Image(systemName: "cube")
                .symbolEffect(.bounce, value: 1)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(.gray.opacity(0.3))
                .clipShape(.rect(cornerSize: .init(width: 10, height: 10)))
                .layoutPriority(1)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.blockNumber.flatMap { String($0) } ?? "Pending")
                        .foregroundStyle(Color.blue)
                        .navigationDestination(isPresented: $activateLinkBlock) {
                            EthBlockDetailedView(viewModel: viewModel.blockDetailViewModel())
                        }
                        .onTapGesture {
                            activateLinkBlock = true
                        }
                    
                    
                    Spacer()

                    Text(viewModel.timestampTitle)
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
                
                
                HStack {
                    Text("Fee Recipient")
                    Text(viewModel.miner)
                        .singleLongLineText()
                        .foregroundStyle(Color.blue)
                        .navigationDestination(isPresented: $activateLinkRecipient) {
                            AddressScreenView(viewModel: .init(address: viewModel.miner))
                        }
                        .onTapGesture {
                            activateLinkRecipient = true
                        }
                }
                
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

