//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import SwiftUI

public struct Smile: Shape {
    var offset: CGFloat
    
    public init(offset: CGFloat) {
        self.offset = offset
    }
    
    public func path(in rect: CGRect) -> Path {
        Path { path in
            
            let centerX = rect.width / 2
            let centerY = rect.height / 2
            let controlXOffset = rect.midX - 5
            let downRadius: CGFloat = ((rect.height*0.8) * offset) - (0.4*rect.height)
            
            path.move(to: CGPoint(x: rect.minX, y: centerY))
            
            let to1 = CGPoint(x: centerX, y: centerY + downRadius)
            let control1 = CGPoint(x: centerX - controlXOffset, y: centerY)
            let control2 = CGPoint(x: centerX - controlXOffset, y: centerY + downRadius)
            
            let to2 = CGPoint(x: rect.maxX, y: centerY)
            let control3 = CGPoint(x: centerX + controlXOffset, y: centerY + downRadius)
            let control4 = CGPoint(x: centerX + controlXOffset, y: centerY)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}

#Preview {
    Smile(offset: 1)
        .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
        .frame(width: 150, height: 80)
}
