//
//  EthTopologhyView.swift
//  EthFuss
//
//  Created by Siarhei Yakushevich on 02/12/2024.
//

import SwiftUI

struct LineView: View {
    var point1: CGPoint
    var point2: CGPoint
    
    var lineWidth: CGFloat = 2.0
    
    var body: some View {
        Path { path in
            path.move(to: point1)
            path.addLine(to: point2)
        }
        .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: [5, 10])) // Dashed line
    }
}

struct EthTopologhyView: View {
    @State private var animateNodes = false
    @State private var rotateThem = false
    @State private var animateConnectors = false
    
    let delay = TimeInterval(0.5)
    var normalizedPositions: [CGPoint] = [.init(x: 0.2,
                                                y: 0.2),
                                          .init(x: 0.8,
                                                y: 0.2),
                                          .init(x: 0.8,
                                                y: 0.8),
                                          .init(x: 0.2,
                                                y: 0.8)]
    
    @ViewBuilder
    private func ComputerConnectorsView(startDelay: TimeInterval,
                                        size: CGSize) -> some View {
        //Lines..
        Group{
            ForEach(0..<normalizedPositions.count - 1, id: \.self) { index in
                let position1 = normalizedPositions[index]
                let point1 = CGPoint(x: size.width * position1.x,
                                     y: size.height * position1.y)
                ForEach(index..<normalizedPositions.count, id: \.self) { index2 in
                    let animationDelay = Double(index * normalizedPositions.count + index2) * delay
                    let position2 = normalizedPositions[index2]
                    let point2 = CGPoint(x: size.width * position2.x,
                                         y: size.height * position2.y)
                    LineView(point1: point1, point2: point2)
                        .opacity(animateConnectors ? 1 : 0)
                        .animation(.default.delay(startDelay + animationDelay), value: animateConnectors)
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            ZStack {
                Color(.systemBackground)
                
                ComputerConnectorsView(startDelay: 5, size: proxy.size)
                
                //Computers...
                Group {
                    ForEach(0..<normalizedPositions.count, id: \.self) { index in
                        let position = normalizedPositions[index]
                        Image(systemName: "desktopcomputer")
                        //.tint(.red)
                            .aspectRatio(contentMode: .fill)
                            .scaledToFill()
                            .scaleEffect(animateNodes ? 1.5 : 0)
                            .symbolEffect(.bounce, value: 2)
                        //.transition(.opacity)
                            .position(x: proxy.size.width * position.x,
                                      y: proxy.size.height * position.y)
                            .animation(.default.delay(Double((index + 1)) * delay), value: animateNodes)
                    }
                }.rotationEffect(.degrees(rotateThem ? 360.0 : 0.0))
                    .animation(.default.delay(delay * (Double(normalizedPositions.count * 2))).speed(1.5),
                               value: rotateThem)
                
                
            }
        }.onAppear {
            /*withAnimation {
                animateNodes = true
            } completion: {
                rotateThem = true
            }*/
            /*withAnimation {
                animateNodes = true
            } completion: {
                withAnimation {
                    rotateThem = true
                } completion: {
                    animateConnectors = true
                }

            }*/

            animateNodes = true
            rotateThem = true
            animateConnectors = true
        }
        .ignoresSafeArea()
    }
}

#Preview {
    EthTopologhyView()
}
