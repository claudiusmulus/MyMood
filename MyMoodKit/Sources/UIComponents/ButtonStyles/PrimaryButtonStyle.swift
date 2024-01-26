//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-17.
//

import SwiftUI

public struct PrimaryButtonStyle<ContentShape: ShapeStyle>: ButtonStyle {
  
  let backgroundStyle: ContentShape
  let cornerRadius: CGFloat
  let scaleFactor: CGFloat
  let font: Font
  let verticalPadding: CGFloat
  
  public init(
    backgroundStyle: ContentShape,
    cornerRadius: CGFloat,
    font: Font,
    scaleFactor: CGFloat,
    verticalPadding: CGFloat
  ) {
    self.backgroundStyle = backgroundStyle
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
          .fill(self.backgroundStyle)
      }
      .scaleEffect(configuration.isPressed ? scaleFactor: 1)
      .animation(.spring(), value: configuration.isPressed)
  }
}

extension View {
  public func primaryButton<ContentShape: ShapeStyle>(
    backgroundStyle: ContentShape,
    cornerRadius: CGFloat = 20,
    font: Font = .title3,
    scaleFactor: CGFloat = 0.90,
    verticalPadding: CGFloat = 15.0
  ) -> some View {
    self.buttonStyle(
      PrimaryButtonStyle(
        backgroundStyle: backgroundStyle,
        cornerRadius: cornerRadius,
        font: font,
        scaleFactor: scaleFactor,
        verticalPadding: verticalPadding
      )
    )
  }
}
