//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-23.
//

import SwiftUI

struct NoteEntryScrollOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

extension View {
  @ViewBuilder
  func scrollOffsetY(completion: @escaping (CGFloat) -> Void) -> some View {
    self
      .overlay {
        GeometryReader {
          let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
          
          Color.clear
            .preference(key: NoteEntryScrollOffsetKey.self, value: minY)
            .onPreferenceChange(NoteEntryScrollOffsetKey.self, perform: completion)
        }
      }
  }
}
