//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-12.
//

import SwiftUI

struct MoodRow: ViewModifier {
    
    let accentColor: Color
    let backgroundColor: Color
  let moodScale: CGFloat
  
    let accentWidth: CGFloat
    let cornerRadius: CGFloat
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowXOffset: CGFloat
    let shadowYOffset: CGFloat
    
    func body(content: Content) -> some View {
//        HStack(spacing: 0) {
//            Rectangle()
//                .fill(accentColor)
//                .frame(width: accentWidth)
//            
//            content
//                }
      HStack(spacing: 0) {
        Rectangle()
          .fill(.black)
          .frame(width: accentWidth)
          .overlay {
            Face(
              eyeSize: CGSize(width: 12, height: 12),
              lineWidth: 2.0,
              offset: self.moodScale,
              smileSize: CGSize(width: 32, height: 32)
            )
            .foregroundStyle(.white)
          }
        content
      }
      .frame(maxWidth: .infinity, alignment: .leading)
        .mask(RoundedRectangle(cornerRadius: cornerRadius))
        .background {
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            //.fill(accentColor)
            .stroke(.black, lineWidth: 2.0)
      
//        content
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .mask(RoundedRectangle(cornerRadius: cornerRadius))
//            .background {
//                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
//                    //.fill(accentColor)
//                .stroke(.black, lineWidth: 2.0)
                    //.shadow(color: shadowColor, radius: shadowRadius, x: shadowXOffset, y: shadowYOffset)
        }
    }
}

extension View {
    public func moodRow(
        accentColor: Color,
        backgroundColor: Color,
        moodScale: CGFloat,
        accentWidth: CGFloat = 50,
        cornerRadius: CGFloat = 20,
        shadowColor: Color = .black.opacity(0.4),
        shadowRadius: CGFloat = 5,
        shadowXOffset: CGFloat = 0,
        shadowYOffset: CGFloat = 2
    ) -> some View {
        self.modifier(
            MoodRow(
                accentColor: accentColor,
                backgroundColor: backgroundColor,
                moodScale: moodScale,
                accentWidth: accentWidth,
                cornerRadius: cornerRadius,
                shadowColor: shadowColor,
                shadowRadius: shadowRadius,
                shadowXOffset: shadowXOffset,
                shadowYOffset: shadowYOffset
            )
        )
    }
}
