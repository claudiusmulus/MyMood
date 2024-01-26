//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-22.
//

import SwiftUI

struct ShowObservationsModifier<ExtraContent: View>: ViewModifier {
  var showObservations: Binding<Bool>
  @ViewBuilder var extraContent: () -> ExtraContent
  
  init(showObservations: Binding<Bool>, @ViewBuilder extraContent: @escaping () -> ExtraContent) {
    self.showObservations = showObservations
    self.extraContent = extraContent
  }
  
  func body(content: Content) -> some View {
    ZStack {
      content
      if showObservations.wrappedValue {
        extraContent()
      }
    }
  }
}

extension View {
  @ViewBuilder
  func showObservations(
    _ showObservations: Binding<Bool>,
    @ViewBuilder content: @escaping () -> some View
  ) -> some View {
    self.modifier(ShowObservationsModifier(showObservations: showObservations, extraContent: content))
  }
}
