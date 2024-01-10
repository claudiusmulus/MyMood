//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-09.
//

import SwiftUI

public struct FilledButtonStyle: ButtonStyle {
    
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let scaleFactor: CGFloat
    
    public init(
        backgroundColor: Color,
        cornerRadius: CGFloat,
        scaleFactor: CGFloat
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.scaleFactor = scaleFactor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .minimumScaleFactor(0.6)
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .fill(self.backgroundColor)
            }
            .scaleEffect(configuration.isPressed ? scaleFactor: 1)
            .animation(.spring(), value: configuration.isPressed)
    }
    
}

public struct RedactedFilledButtonStyle<ContentShape: ShapeStyle>: ButtonStyle {
    
    let condition: () -> Bool
    let backgroundStyle: (Bool) -> ContentShape
    let cornerRadius: CGFloat
    let scaleFactor: CGFloat
    
    public init(
        condition: @escaping () -> Bool,
        backgroundStyle: @escaping (Bool) -> ContentShape,
        cornerRadius: CGFloat,
        scaleFactor: CGFloat
    ) {
        self.condition = condition
        self.backgroundStyle = backgroundStyle
        self.cornerRadius = cornerRadius
        self.scaleFactor = scaleFactor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .minimumScaleFactor(0.6)
            .padding(15)
            .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
            .background {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .fill(self.backgroundStyle(condition()))
            }
            .scaleEffect(configuration.isPressed ? scaleFactor: 1)
            .animation(.spring(), value: configuration.isPressed)
    }
    
}

extension View {
    public func redactedFillButton(
        if condition: @autoclosure @escaping () -> Bool,
        backgroundColor: Color,
        cornerRadius: CGFloat = 10,
        scaleFactor: CGFloat = 0.90
    ) -> some View {
        self.buttonStyle(
            RedactedFilledButtonStyle(
                condition: condition,
                backgroundStyle: {
                    $0 ?
                    LinearGradient(colors: [.black.opacity(0.25), .black.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                    :
                    LinearGradient(colors: [backgroundColor], startPoint: .leading, endPoint: .trailing)
                },
                cornerRadius: cornerRadius,
                scaleFactor: scaleFactor
            )
        )
    }
}

extension View {
    public func filledButton(
        backgroundColor: Color,
        cornerRadius: CGFloat = 10,
        scaleFactor: CGFloat = 0.90
    ) -> some View {
        self.buttonStyle(
            FilledButtonStyle(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                scaleFactor: scaleFactor
            )
        )
    }
}
