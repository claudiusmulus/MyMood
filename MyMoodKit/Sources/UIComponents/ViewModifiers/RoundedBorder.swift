//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-09.
//

import SwiftUI

struct RoundedBorder: ViewModifier {
    
    let borderColor: Color
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: self.cornerRadius)
                    .stroke(self.borderColor, lineWidth: self.lineWidth)
            }
    }
}

extension View {
    public func roundedBorder(
        borderColor: Color,
        cornerRadius: CGFloat = 10.0,
        lineWidth: CGFloat = 2.0
    ) -> some View {
        self.modifier(RoundedBorder(borderColor: borderColor, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}
