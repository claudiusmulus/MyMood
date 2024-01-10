//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import SwiftUI

public struct Face: View {
        
    let eyeSize: CGSize
    let smileSize: CGSize
    
    let offset: CGFloat
    
    public init(eyeSize: CGSize, smileSize: CGSize, offset: CGFloat) {
        self.eyeSize = eyeSize
        self.smileSize = smileSize
        self.offset = offset
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                ForEach(1...2, id: \.self) { _ in
                    ZStack {
                        Eye()
                            .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .frame(width: eyeSize.width)
                        
                        Eye(offset: offset)
                            .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                            .frame(width: eyeSize.width)
                            .rotationEffect(.degrees(180))
                        
                        Circle()
                            .fill(.black)
                            .frame(
                                width: eyeSide(amount: offset),
                                height: eyeSide(amount: offset)
                            )
                            .offset(y: 10)
                    }
                    .frame(height: eyeSize.height)
                }

            }
            Smile(offset: CGFloat(offset))
                .stroke(style: .init(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .frame(width: smileSize.width, height: smileSize.height)
        }
    }
    
    func eyeSide(amount: CGFloat) -> CGFloat {
        amount * 8 + 6
    }
}

#Preview {
    Face(
        eyeSize: CGSize(width: 50, height: 50),
        smileSize: CGSize(width: 150, height: 80),
        offset: 0.5
    )
}
