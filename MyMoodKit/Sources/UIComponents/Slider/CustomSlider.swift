//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import SwiftUI

public struct CustomSlider: View {
    
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    public init(value: Binding<Double>, range: ClosedRange<Double>) {
        self._value = value
        self.range = range
    }
    
    @State private var lastOffset: Double = 0
    
    private let leadingOffset: Double = 0
    private let trailingOffset: Double = 0
    
    var knobSize: CGSize = CGSize(width: 40, height: 40)
    
    public var body: some View {
        GeometryReader {
            let width = $0.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black)
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                
                Image(systemName: "arrow.left.and.right")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: knobSize.width, height: knobSize.height)
                    .background {
                        RoundedRectangle(cornerRadius: 10).fill(.black).shadow(color: .black.opacity(0.6), radius: 8)
                    }
                    .offset(x: self.$value.wrappedValue.map(from: self.range, to: self.leadingOffset...(width - self.knobSize.width - self.trailingOffset)))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if abs(value.translation.width) < 0.1 {
                                    self.lastOffset = self.$value.wrappedValue.map(from: self.range, to: self.leadingOffset...(width - self.knobSize.width - self.trailingOffset))
                                }
                                
                                let sliderPos = max(self.leadingOffset, min(self.lastOffset + value.translation.width, width - self.trailingOffset - self.knobSize.width))
                                self.value = sliderPos.map(from: self.leadingOffset...(width - self.knobSize.width - self.trailingOffset), to: self.range)
                            }
                    )
            }

        }
    }
}


fileprivate extension Double {
    func map(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}

#Preview {
    CustomSlider(value: .constant(0.5), range: 0...1)
}
