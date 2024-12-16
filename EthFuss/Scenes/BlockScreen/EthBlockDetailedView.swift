//
//  EthBlockDetailedView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 13/12/2024.
//

import SwiftUI

struct EthBlockDetailedView: View {
    @ObservedObject var viewModel: EthBlockDetailedViewModel
    @State var blockHeightFrame: CGRect = .zero // coupld be used from VM... dic for each type..
    @State var blockDifficultyFrame: CGRect = .zero // coupld be used from VM... dic for each type..
    @State var isHeightPopup: Bool?
    @State var toolTipText: String?
    @Namespace var innerNamespace
    
    @ViewBuilder
    private func toolTipButtonView(_ toolTip: String,
                                   label: String,
                                   frameBinding: Binding<CGRect>,
                                   isHeight: Bool?) -> some View {
        FrameObservingView(coordinateSpace: .named(innerNamespace),
                           frame: frameBinding) {
            Button(label, systemImage: "questionmark.circle") {
                toolTipText = toolTip
                isHeightPopup = isHeight
            }.foregroundStyle(.black)
                .tint(.black)
        }
    }
    
    @ViewBuilder
    private func rowView(_ info: EthBlockDetailedViewModel.TopSectionRowInfo) -> some View {
        switch info.type {
        case .blockHeight(let toolTip, let label, let number, let hasPrevious, let hasNext):
            HStack {
                toolTipButtonView(toolTip,
                                  label: label,
                                  frameBinding: $blockHeightFrame,
                                  isHeight: true)
                .layoutPriority(1)
                
                Spacer()
                
                Text(number)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
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
                toolTipButtonView(toolTip,
                                  label: label,
                                  frameBinding: $blockDifficultyFrame,
                                  isHeight: false)
                .layoutPriority(1)
                
                Spacer()
                
                Text(number)
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
                                .transition(.move(edge: .leading))
                                .animation(.default, value: viewModel.topSectionRows.count)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .coordinateSpace(.named(innerNamespace))
        .overlay() {
                if let toolTipText, let isHeightPopup {
                    Color.black.opacity(0.2).ignoresSafeArea(edges:. vertical)
                        .onTapGesture {
                            withAnimation {
                                self.toolTipText = nil //reset...
                                self.isHeightPopup = nil
                            }
                        }
                    Text(toolTipText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: .init(5)))
                        .alignmentGuide(HorizontalAlignment.center, computeValue: { d in
                            let origin = (isHeightPopup ? blockHeightFrame : blockDifficultyFrame).origin
                            return -(origin.x - d[HorizontalAlignment.center])
                        })
                        .alignmentGuide(VerticalAlignment.center, computeValue: { _ in
                            /*let origin = (isHeightPopup ? blockHeightFrame : blockDifficultyFrame).origin
                            return (origin.y - d[VerticalAlignment.center])*/
                            return 0
                        })
                        //.position((isHeightPopup ? blockHeightFrame : blockDifficultyFrame).origin)
                }
            }
    }
    
    
    @ViewBuilder var bodyCore: some View {
        ZStack {
            contentView
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.gray)
            }
        }
            //.transition(.move(edge: .leading))
    }
    
    var body: some View {
        bodyCore
            .navigationTitle(viewModel.title ?? "")
    }
}
