  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2023-12-12.
  //

import SwiftUI

struct MoodSingleRow: ViewModifier {

  let accentColor: Color
  let accentWidth: CGFloat
  let backgroundColor: Color
  let cornerRadius: CGFloat
  let shadowColor: Color
  let shadowRadius: CGFloat
  let shadowXOffset: CGFloat
  let shadowYOffset: CGFloat
  
  func body(content: Content) -> some View {
    
    HStack(alignment: .top, spacing: 0) {
      RoundedRectangle(cornerRadius: self.accentWidth * 0.25)
        .fill(self.accentColor)
        .frame(width: self.accentWidth, height: self.accentWidth)
        .padding(.trailing, 10)
      
      content
    }
    .padding()    
    .frame(maxWidth: .infinity, alignment: .leading)
    .mask(RoundedRectangle(cornerRadius: cornerRadius))
    .background {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(self.backgroundColor)
        .shadow(color: shadowColor, radius: shadowRadius, x: shadowXOffset, y: shadowYOffset)
    }
  }
}

struct MoodAverageRow: ViewModifier {
  
  let backgroundColor: Color
  let cornerRadius: CGFloat
  let shadowColor: Color
  let shadowRadius: CGFloat
  let shadowXOffset: CGFloat
  let shadowYOffset: CGFloat
  
  func body(content: Content) -> some View {
    content
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .mask(RoundedRectangle(cornerRadius: cornerRadius))
      .background {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .fill(self.backgroundColor)
          .shadow(color: shadowColor, radius: shadowRadius, x: shadowXOffset, y: shadowYOffset)
      }
  }
}


struct MoodSectionRow: ViewModifier {
  
  let accentColor: Color
  let backgroundColor: Color
  let dividerColor: Color
  
  func body(content: Content) -> some View {
    VStack(spacing: 0) {
      dividerColor.frame(height: 1)
        .frame(maxWidth: .infinity)
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .mask(Rectangle())
    .background {
      Rectangle()
        .fill(self.backgroundColor)
    }
  }
}

struct MoodSectionModifier: ViewModifier {
  
  let cornerRadius: CGFloat
  let shadowColor: Color
  let shadowRadius: CGFloat
  let shadowXOffset: CGFloat
  let shadowYOffset: CGFloat
  
  func body(content: Content) -> some View {
    content
      .compositingGroup()
      .mask(
        RoundedRectangle(cornerRadius: cornerRadius)
      )
      .background {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          .foregroundStyle(.white)
          .shadow(color: shadowColor, radius: shadowRadius, x: shadowXOffset, y: shadowYOffset)
      }
  }
}

extension View {
  public func moodSingleRow(
    accentColor: Color,
    accentWidth: CGFloat = 30.0,
    backgroundColor: Color,
    cornerRadius: CGFloat = 20,
    shadowColor: Color = .black.opacity(0.2),
    shadowRadius: CGFloat = 2,
    shadowXOffset: CGFloat = 0,
    shadowYOffset: CGFloat = 2
  ) -> some View {
    self.modifier(
      MoodSingleRow(
        accentColor: accentColor,
        accentWidth: accentWidth,
        backgroundColor: backgroundColor,
        cornerRadius: cornerRadius,
        shadowColor: shadowColor,
        shadowRadius: shadowRadius,
        shadowXOffset: shadowXOffset,
        shadowYOffset: shadowYOffset
      )
    )
  }
  
  public func moodSection(
    cornerRadius: CGFloat = 20,
    shadowColor: Color = .black.opacity(0.2),
    shadowRadius: CGFloat = 2,
    shadowXOffset: CGFloat = 0,
    shadowYOffset: CGFloat = 2
  ) -> some View {
    self.modifier(
      MoodSectionModifier(
        cornerRadius: cornerRadius,
        shadowColor: shadowColor,
        shadowRadius: shadowRadius,
        shadowXOffset: shadowXOffset,
        shadowYOffset: shadowYOffset
      )
    )
  }
  
  public func moodSectionRow(
    accentColor: Color,
    backgroundColor: Color,
    dividerColor: Color
  ) -> some View {
    self.modifier(
      MoodSectionRow(
        accentColor: accentColor,
        backgroundColor: backgroundColor,
        dividerColor: dividerColor
      )
    )
  }
  
  public func moodAverage(
    backgroundColor: Color,
    cornerRadius: CGFloat = 20,
    shadowColor: Color = .black.opacity(0.2),
    shadowRadius: CGFloat = 2,
    shadowXOffset: CGFloat = 0,
    shadowYOffset: CGFloat = 2
  ) -> some View {
    self.modifier(
      MoodAverageRow(
        backgroundColor: backgroundColor,
        cornerRadius: cornerRadius,
        shadowColor: shadowColor,
        shadowRadius: shadowRadius,
        shadowXOffset: shadowXOffset,
        shadowYOffset: shadowYOffset
      )
    )
  }
}
