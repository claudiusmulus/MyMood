//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-19.
//

import SwiftUI
import ComposableArchitecture
import Theme

extension DependencyValues {
    public var colorGenerator: ColorGeneratorClient {
      get { self[ColorGeneratorClient.self] }
      set { self[ColorGeneratorClient.self] = newValue }
    }
}

extension ColorGeneratorClient: DependencyKey {
    public static var liveValue: ColorGeneratorClient {
        .live(
            initialColorResolved: Color(.moodVariationRed).rgba,
            middleColorResolved: Color(.moodVariationYellow).rgba,
            finalColorResolved: Color(.moodVariationGreen).rgba
        )
    }
}
