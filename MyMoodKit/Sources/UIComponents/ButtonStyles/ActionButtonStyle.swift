//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-04.
//

import SwiftUI

public struct ActionButtonStyle: ButtonStyle {

    let borderColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let scaleFactor: CGFloat
    
    public init(
        borderColor: Color,
        borderWidth: CGFloat,
        cornerRadius: CGFloat,
        scaleFactor: CGFloat
    ) {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.scaleFactor = scaleFactor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .fontWeight(.medium)
            .minimumScaleFactor(0.6)
            .padding(.vertical, 20)
            .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
            .background {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .stroke(self.borderColor, lineWidth: self.borderWidth)
            }
            .scaleEffect(configuration.isPressed ? scaleFactor: 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension View {
    public func actionButton(
        borderColor: Color,
        borderWidth: CGFloat = 3.0,
        cornerRadius: CGFloat = 20,
        scaleFactor: CGFloat = 0.95
    ) -> some View {
        self.buttonStyle(ActionButtonStyle(borderColor: borderColor, borderWidth: borderWidth, cornerRadius: cornerRadius, scaleFactor: scaleFactor))
    }
}
