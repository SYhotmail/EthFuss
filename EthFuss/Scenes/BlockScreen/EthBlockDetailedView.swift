//
//  EthBlockDetailedView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct EthBlockDetailedView: View {
    @ObservedObject var viewModel: EthBlockDetailedViewModel
    var body: some View {
        List {
            
        }.navigationTitle(viewModel.title ?? "")
    }
}
