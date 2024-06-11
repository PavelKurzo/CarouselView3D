
//  ContentView.swift
//  CarouselView
//
//  Created by Pavel Kurzo on 10/06/2024.
//

import SwiftUI

enum Name: String, CaseIterable, Codable {
    case first
    case second
    case third
    case fourth
    case fifth
    
    static var count: Int {
        Self.allCases.count
    }
    
    var index: Int {
        switch self {
        case .first:
            return 0
        case .second:
            return 1
        case .third:
            return 2
        case .fourth:
            return 3
        case .fifth:
            return 4
        }
    }
    
    var name: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .first:
            return Color.orange
        case .second:
            return Color.blue
        case .third:
            return Color.pink
        case .fourth:
            return Color.green
        case .fifth:
            return Color.purple
        }
    }
}

struct ContentView: View {
    @State var dragAmount = CGSize.zero
    @State var activeIndex: Int = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(Name.allCases.enumerated()), id: \.element.index) { index, type in
                    VStack {
                        Text("\(activeIndex)")
                        Text(type.name)
                            .font(.title2)
                            .frame(width: 100, height: 100)
                        Text("\(index)")
                            .padding()
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(type.color))
                    .scaleEffect(scale(for: index))
                    .offset(x: getOffset(index))
                    .zIndex(zIndex(for: index))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(maxHeight: .infinity, alignment: .center)
            .gesture(DragGesture()
                .onChanged { value in
                    dragAmount = value.translation
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        withAnimation {
                            activeIndex = (activeIndex - 1 + Name.count) % Name.count
                        }
                    } else if value.translation.width > threshold {
                        withAnimation {
                            activeIndex = (activeIndex + 1) % Name.count
                        }
                    }
                    dragAmount = .zero
                }
            )
        }
    }
    
    func scale(for index: Int) -> CGFloat {
        let maxScale: CGFloat = 1.0
        let minScale: CGFloat = 0.7
        
        let distanceFromActive = (index - activeIndex + Name.count) % Name.count
        var scaleFactor: CGFloat
        
        switch distanceFromActive {
        case 0:
            scaleFactor = maxScale
        case 1, Name.count - 1:
            scaleFactor = minScale
        case 2, Name.count - 2:
            scaleFactor = minScale * 0.8
        default:
            scaleFactor = minScale * 0.6
        }
        
        return scaleFactor
    }
    
    func getOffset(_ item: Int) -> Double {
        let centerIndex = Name.count / 2
        let normalizedActiveIndex = activeIndex % Name.count
        
        var distanceToCenter = item - normalizedActiveIndex
        if distanceToCenter > centerIndex {
            distanceToCenter -= Name.count
        } else if distanceToCenter < -centerIndex {
            distanceToCenter += Name.count
        }
        
        let adjacentOffset: Double = -80
        let nonAdjacentOffset: Double = -120
        
        let offset = distanceToCenter == 0 ? 0 : (abs(distanceToCenter) == 1 ? adjacentOffset : nonAdjacentOffset) * (distanceToCenter < 0 ? -1 : 1)
        
        return offset
    }
    
    func zIndex(for index: Int) -> Double {
        let distanceFromActive = (index - activeIndex + Name.count) % Name.count
        if distanceFromActive == 0 {
            return Double(Name.count)
        } else {
            return Double(abs(distanceFromActive - Name.count / 2))
        }
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
