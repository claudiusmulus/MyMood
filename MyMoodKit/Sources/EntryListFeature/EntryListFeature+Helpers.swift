//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-31.
//

import Models
import SwiftUI
import ComposableArchitecture
import Foundation
import ColorGeneratorClient

extension IdentifiedArray where Element == Entry {
  var moodAverageColor: Color {
    @Dependency(\.colorGenerator) var colorGenerator
    
    guard self.count > 0 else {
      return Color(colorGenerator.generatedColor(0.5))
    }
    
    let sum = self.compactMap(/Entry.mood).map(\.moodScale).reduce(0, +)
    let moodScaleAverage =  Float(sum) / Float(self.count)
    
    return Color(colorGenerator.generatedColor(moodScaleAverage))
  }
  
  var moodAverage: Mood? {
    guard self.count > 0 else {
      return nil
    }
    let sum = self.compactMap(/Entry.mood).map(\.moodScale).reduce(0, +)
    
    let moodScaleAverage =  Double(sum) / Double(self.count)
    
    return moodScaleAverage.mood()
  }
}
