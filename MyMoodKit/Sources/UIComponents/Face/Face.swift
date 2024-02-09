  //
  //  SwiftUIView.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-03.
  //

import SwiftUI

public struct Face: View {
  
  let eyeColor: Color
  let eyeSize: CGSize
  let smileSize: CGSize
  
  let lineWidth: CGFloat
  
  let offset: CGFloat
  
  let eyesSpacing: CGFloat
  let eyeDotOffset: CGFloat
  
  public init(
    eyeColor: Color = .black,
    eyeSize: CGSize,
    lineWidth: CGFloat = 5.0,
    offset: CGFloat,
    smileSize: CGSize
  ) {
    self.eyeColor = eyeColor
    self.eyeSize = eyeSize
    self.lineWidth = lineWidth
    self.smileSize = smileSize
    self.offset = offset
    
    self.eyesSpacing = 0.4 * eyeSize.width
    self.eyeDotOffset = eyeSize.height / 5
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: self.eyesSpacing) {
        ForEach(1...2, id: \.self) { _ in
          ZStack {
            Eye()
              .stroke(style: .init(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round))
              .frame(width: self.eyeSize.width)
            
            Eye(offset: offset)
              .stroke(style: .init(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round))
              .frame(width: self.eyeSize.width)
              .rotationEffect(.degrees(180))
            
            Circle()
//              .fill(self.eyeColor)
              .frame(
                width: self.eyeSide(amount: self.offset),
                height: self.eyeSide(amount: self.offset)
              )
              .offset(y: self.eyeDotOffset)
          }
          .frame(height: self.eyeSize.height)
        }
        
      }
      Smile(offset: CGFloat(self.offset))
        .stroke(style: .init(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round))
        .frame(width: self.smileSize.width, height: self.smileSize.height)
    }
  }
  
  func eyeSide(amount: CGFloat) -> CGFloat {
    amount * (0.16 * eyeSize.height) + (0.12 * eyeSize.height)
  }
}

#Preview("Small") {
  Face(
    eyeSize: CGSize(width: 15, height: 15),
    lineWidth: 2.0,
    offset: 0.5,
    smileSize: CGSize(width: 40, height: 30)
  )
}

#Preview("Default") {
  Face(
    eyeSize: CGSize(width: 50, height: 50),
    lineWidth: 2.0,
    offset: 0,
    smileSize: CGSize(width: 150, height: 80)
  )
}
