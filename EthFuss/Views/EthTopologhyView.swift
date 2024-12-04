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
        Self.path(point1: point1,
                  point2: point2)
        .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                   dash: [5, 10])) // Dashed line
    }
    
    static func path(point1: CGPoint, point2: CGPoint) -> Path {
        Path { path in
            path.move(to: point1)
            path.addLine(to: point2)
        }
    }
}

struct PulsedLineView: View {
    @State private var animationProgress: CGFloat = 0.0
    
    var point1: CGPoint
    var point2: CGPoint
    
    var body: some View {
        ZStack {
            LineView(point1: point1,
                     point2: point2)
            
            /*GeometryReader { proxy in
                let path = LineView.path(point1: point1,
                                         point2: point2)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2, height: 2)
                    //.scaleEffect(.init(2))
                    .position(/*Self.positionOnPath(path,
                                                  at: animationProgress) */
                        Self.positionOnPath(point1: point1,
                                            point2: point2,
                                            at: animationProgress))
            } */
            Rectangle()
                .fill(Color.blue)
                .frame(width: 2, height: 2)
                .scaleEffect(.init(2))
                .position(
                    Self.positionOnPath(point1: point1,
                                        point2: point2,
                                        at: animationProgress))
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
                animationProgress = 1.0
            }
        }
    }
    
    // Helper function to calculate the position on a path
    static func positionOnPath(point1: CGPoint,
                               point2: CGPoint,
                               at progress: CGFloat) -> CGPoint {
            var vector = CGPoint(x: point2.x - point1.x,
                                 y: point2.y - point1.y)
            
            let d = sqrt(vector.x * vector.x + vector.y * vector.y)
            
            guard d != 0 else {
                return point1
            }
        
            //vector.x /= d
            //vector.y /= d
        
            //assert((vector.x * vector.x + vector.y * vector.y) == 1.0)
            
            /*let trimmedPath = path.trimmedPath(from: 0, to: progress)
            return trimmedPath.currentPoint ?? .zero */
            
            return .init(x: point1.x + progress * vector.x,
                         y: point1.y + progress * vector.y)
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
                    let animationDelay = Double(index * normalizedPositions.count + index2 * 0) * delay //same delay for each node...
                    let position2 = normalizedPositions[index2]
                    let point2 = CGPoint(x: size.width * position2.x,
                                         y: size.height * position2.y)
                    PulsedLineView(point1: point1,
                                   point2: point2)
                        .opacity(animateConnectors ? 1 : 0)
                        .animation(.default.delay(startDelay + animationDelay), value: animateConnectors)
                }
            }
        }
    }
    
    var rotateComputersDelay: TimeInterval {
        delay * Double(normalizedPositions.count) + approximateDefaultDuration * rotateComputesSpeed
    }
    
    let rotateComputesSpeed: TimeInterval = 1.5
                 
    let approximateDefaultDuration = TimeInterval(0.35)
    
    
    
    var body: some View {
        GeometryReader { proxy in
            
            ZStack {
                Color(.systemBackground)
                
                ComputerConnectorsView(startDelay: 5,
                                       size: proxy.size)
                
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
                            .background(Capsule().fill(Color.white))
                            .position(x: proxy.size.width * position.x,
                                      y: proxy.size.height * position.y)
                            .animation(.default.delay(Double((index + 1)) * delay), value: animateNodes)
                    }
                }.rotationEffect(.degrees(rotateThem ? 360.0 : 0.0))
                    .animation(.default.delay(rotateComputersDelay)
                             .speed(rotateComputesSpeed),
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
