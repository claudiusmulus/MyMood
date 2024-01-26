//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-04.
//

import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
  
  let borderColor: Color
  let borderWidth: CGFloat
  let cornerRadius: CGFloat
  let scaleFactor: CGFloat
  let font: Font
  let verticalPadding: CGFloat
  
  public init(
    borderColor: Color,
    borderWidth: CGFloat,
    cornerRadius: CGFloat,
    font: Font,
    scaleFactor: CGFloat,
    verticalPadding: CGFloat
  ) {
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.cornerRadius = cornerRadius
    self.font = font
    self.scaleFactor = scaleFactor
    self.verticalPadding = verticalPadding
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(self.font)
      .fontWeight(.medium)
      .minimumScaleFactor(0.6)
      .padding(.vertical, self.verticalPadding)
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
  public func secondaryButton(
    borderColor: Color,
    borderWidth: CGFloat = 3.0,
    cornerRadius: CGFloat = 20,
    font: Font = .title3,
    scaleFactor: CGFloat = 0.90,
    verticalPadding: CGFloat = 15.0
  ) -> some View {
    self.buttonStyle(
      SecondaryButtonStyle(
        borderColor: borderColor,
        borderWidth: borderWidth,
        cornerRadius: cornerRadius,
        font: font,
        scaleFactor: scaleFactor,
        verticalPadding: verticalPadding
      )
    )
  }
}
