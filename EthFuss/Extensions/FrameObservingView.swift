//
//  FrameObservingView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 16/12/2024.
//

import SwiftUI

// MARK: - FrameObservingView
struct FrameObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace = .global
    var notifyAsync = true
    @Binding var frame: CGRect

    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(key: Self.PreferenceKey.self,
                                       value: geometry.frame(in: coordinateSpace))
            })
            .onPreferenceChange(Self.PreferenceKey.self) { frame in
                runOnMain {
                    self.frame = frame
                }
            }
    }
    
    private func runOnMain(block: @escaping () -> ()) {
        assert(Thread.isMainThread)
        
        let method =  notifyAsync ? DispatchQueue.main.async(execute: ) : DispatchQueue.main.sync(execute: )
        method(.init(block: block))
    }
}

// MARK: FrameObservingView.PreferenceKey
extension FrameObservingView {
    fileprivate struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGRect { .zero }

        static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
            // No-op
            // value = nextValue()
        }
    }
}
