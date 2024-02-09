//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import SwiftUI
import Models

public struct MoodEntryAverage {
  let averageColor: Color
  let entryCount: Int
  let mood: Mood
  
  public init(averageColor: Color, entryCount: Int, mood: Mood) {
    self.averageColor = averageColor
    self.entryCount = entryCount
    self.mood = mood
  }
}

public struct MoodEntryAverageView: View {
  
  let averageInfo: MoodEntryAverage
  public init(averageInfo: MoodEntryAverage) {
    self.averageInfo = averageInfo
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack {
        Text("Your average mood")
          .font(.body)
        
        Spacer()
        
        Text("(Base on \(self.averageInfo.entryCount) answers)")
          .font(.caption)
          .foregroundStyle(.black)
          
      }


      Text(self.averageInfo.mood.title)
        .foregroundStyle(.black)
        .font(.title3.bold())
        .fontWeight(.heavy)
        .minimumScaleFactor(0.6)
        .lineLimit(1)
    }
    .moodAverage(backgroundColor: self.averageInfo.averageColor)
  }
}

#Preview {
  MoodEntryAverageView(
    averageInfo: .init(
      averageColor: .moodGreen,
      entryCount: 3,
      mood: .awesome
    )
  )
  .padding()
}
