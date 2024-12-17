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
            let vector = CGPoint(x: point2.x - point1.x,
                                 y: point2.y - point1.y)
            
            let d = sqrt(vector.x * vector.x + vector.y * vector.y)
            
            guard d != 0 else {
                return point1
            }
        
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
    
    @State var displayPartId: String!
    
    var body: some View {
        GeometryReader { reader in
            ScrollViewReader { proxy in
                ScrollView(.horizontal.union(.vertical)) {
                    LazyHStack(spacing: 0) {
                        bodyLeftPart
                            .frame(size: reader.size)
                            .id("left")
                        bodyRightPart
                            .frame(size: reader.size)
                            .id("right")
                            .padding(.horizontal, 10)
                    }
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    displayPartId = "left"
                }
                .onChange(of: displayPartId) { oldValue, newValue in
                    guard oldValue != newValue, let newValue else {
                        return
                    }
                    
                    withAnimation(.default) {
                        proxy.scrollTo(newValue, anchor: .leading)
                    } completion: {
                        swapDisplayPartId()
                    }
                }
            }
        }
    }
    
    private func swapDisplayPartId() {
        guard displayPartId == "left" else {
            return
        }
        
        Task { @MainActor in
            displayPartId = "right"
        }
    }
    
    @ViewBuilder
    private func computerView() -> some View {
        Image(systemName: "desktopcomputer")
            .aspectRatio(contentMode: .fill)
            .scaledToFill()
            .scaleEffect(animateNodes ? 1.5 : 0)
            .symbolEffect(.bounce, value: 2)
            .background(Capsule().fill(Color.white))
    }
    
    
    var bodyLeftPart: some View {
        GeometryReader { proxy in
            ZStack {
                Color(.systemBackground)
                
                HStack(spacing: 0) {
                    computerView().alignmentGuide(.top) { dimensions in
                        dimensions[.top] + 50
                    }.padding(.horizontal, 10)
                    
                    VStack {
                        //Spacer()
                        Text("JSON - RPC")
                            .font(.headline)
                            .offset(x: 0, y: 0)
                            .zIndex(1) //in front...
                        
                        Image(systemName: "cloud.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.blue.tertiary.opacity(0.5))
                            .symbolEffect(.breathe, options: .repeating)
                            .frame(size: .init(width: proxy.size.width * 0.8, height: proxy.size.height * 0.5))
                            .opacity(0.9)
                        
                        //Spacer()
                    }.fixedSize(horizontal: false, vertical: true)
                        //.symbolEffect(.appear, value: 2)
                    /*
                    CloudShape()
                                .fill(Color.blue.opacity(0.3))
                                .frame(size: .init(width: 200, height: 200))
                                .overlay(
                                    CloudShape()
                                        .stroke(Color.blue,
                                                lineWidth: 2)
                                        .frame(size: .init(width: 200, height: 200))
                                )
                                .padding()
                     */
                }
                
            }
        }
    }
    
    
    var bodyRightPart: some View {
        GeometryReader { proxy in
            
            ZStack {
                Color(.systemBackground)
                
                ComputerConnectorsView(startDelay: 5,
                                       size: proxy.size)
                //Computers...
                Group {
                    ForEach(0..<normalizedPositions.count, id: \.self) { index in
                        let position = normalizedPositions[index]
                        computerView()
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

// MARK: - CloudShape

/*
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height
            
            // Cloud base
            path.addEllipse(in: CGRect(x: width * 0.25,
                                       y: height * 0.5,
                                       width: width * 0.5,
                                       height: height * 0.4))
            
            // Left puff
            path.addEllipse(in: CGRect(x: width * 0.1,
                                       y: height * 0.4,
                                       width: width * 0.35,
                                       height: height * 0.5))
            
            // Right puff
            path.addEllipse(in: CGRect(x: width * 0.55,
                                       y: height * 0.4,
                                       width: width * 0.35,
                                       height: height * 0.5))
            
            // Top puff
            path.addEllipse(in: CGRect(x: width * 0.3,
                                       y: height * 0.2,
                                       width: width * 0.4,
                                       height: height * 0.5))
        }
    }
} */

extension View {
    func frame(size: CGSize,
               alignment: Alignment = .center) -> some View {
        frame(width: size.width,
              height: size.height,
              alignment: alignment)
    }
}
