//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-17.
//

import SwiftUI

struct HTabContainerOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

extension View {
  @ViewBuilder
  func tabContainerOffsetX(completion: @escaping (CGFloat) -> Void) -> some View {
    self
      .overlay {
        GeometryReader {
          let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
          
          Color.clear
            .preference(key: HTabContainerOffsetKey.self, value: minX)
            .onPreferenceChange(HTabContainerOffsetKey.self, perform: completion)
        }
      }
  }
}
