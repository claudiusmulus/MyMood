//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-18.
//

import SwiftUI

public struct ScaledButtonStyle: ButtonStyle {

    let scaleFactor: CGFloat
    public init(scaleFactor: CGFloat) {
        self.scaleFactor = scaleFactor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .minimumScaleFactor(0.6)
            .scaleEffect(configuration.isPressed ? scaleFactor: 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension View {
    public func scaledButton(scaleFactor: CGFloat = 0.95) -> some View {
        self.buttonStyle(ScaledButtonStyle(scaleFactor: scaleFactor))
    }
}
