//
//  EthBlockDetailedView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct EthBlockDetailedView: View {
    @ObservedObject var viewModel: EthBlockDetailedViewModel
    //@State var isShowing = [EthBlockDetailedViewModel.TopSectionRowType.Inner: Bool]()
    @State var isShowingBlockHeight = false
    @State var isShowingDifficult = false
    @State var isShowingSize = false
    
    private func toolTipButtonView(_ toolTip: String,
                                   label: String,
                                   inner: EthBlockDetailedViewModel.TopSectionRowType.Inner,
                                   binding: Binding<Bool>) -> some View {
        return Button(label, systemImage: "questionmark.circle") {
            isShowingBlockHeight = false
            isShowingDifficult = false
            isShowingSize = false
            binding.wrappedValue = true
            switch inner { //TODO: why binding is not enough?
            case .blockHeight:
                isShowingBlockHeight = true
            case .difficult:
                isShowingDifficult = true
            case .blockSize:
                isShowingSize  = true
            }
            assert([isShowingDifficult, isShowingBlockHeight, isShowingSize].count(where: { $0 }) == 1)
            //TODO: fixme why not all popovers are shown iOS 18.2 (Simulator)
        }.foregroundStyle(.black)
            .buttonStyle(.plain)
            .tint(.black)
            .popover(isPresented: binding) {
            Text(toolTip)
                .padding(.horizontal, 10)
                .clipShape(.rect(cornerRadius: .init(5)))
                .presentationCompactAdaptation((.popover))
        }
    }
    
    
    private func binding(_ info: EthBlockDetailedViewModel.TopSectionRowInfo) -> Binding<Bool> {
        switch info.type {
        case .blockHeight:
            $isShowingBlockHeight
        case .difficulty:
            $isShowingDifficult
        case .blockSize:
            $isShowingSize
        }
    }
    
    
    private func rowView(_ info: EthBlockDetailedViewModel.TopSectionRowInfo) -> some View {
        let tuple = info.type.prevNextBlockHeightButtons()
        return HStack {
            toolTipButtonView(info.type.toolTip,
                              label: info.type.label,
                              inner: info.type.innerSize,
                              binding: binding(info))
            .layoutPriority(1)
            
            Spacer()
            
            Text(info.type.number)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            if let tuple  {
                
                Image(systemName: "arrowshape.backward")
                    .padding(5)
                    .opacity(tuple.hasPrevious ? 1 : 0.5)
                    .onTapGesture(perform: viewModel.loadPrev)
            
                Image(systemName: "arrowshape.forward")
                    .padding(5)
                    .opacity(tuple.hasNext ? 1 : 0.5)
                    .onTapGesture(perform: viewModel.loadNext)
            }
        }
    }
    
    @ViewBuilder var contentView: some View {
        List {
            if !viewModel.topSectionRows.isEmpty {
                Section {
                    VStack(spacing: 0) {
                        ForEach(viewModel.topSectionRows) {
                            rowView($0)
                                .selectionDisabled()
                                .transition(.move(edge: .leading))
                                .animation(.default, value: viewModel.topSectionRows.count)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    
    @ViewBuilder var bodyCore: some View {
        ZStack {
            contentView
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.gray)
            }
        }
    }
    
    var body: some View {
        bodyCore
            .navigationTitle(viewModel.title ?? "")
    }
}
