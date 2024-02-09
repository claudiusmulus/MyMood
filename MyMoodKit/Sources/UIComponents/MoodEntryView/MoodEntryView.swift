//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import SwiftUI
import Models

public struct MoodEntryView: View {
  
  let moodEntry: MoodEntry
  let formattedDate: String
  
  public init(moodEntry: MoodEntry, formattedDate: String) {
    self.moodEntry = moodEntry
    self.formattedDate = formattedDate
  }
  
  public var body: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 5) {
        
        Group {
          Text("You felt ").foregroundStyle(.gray) +
          Text(moodEntry.mood.title).foregroundStyle(.black).fontWeight(.heavy)
        }
        .minimumScaleFactor(0.6)
        .lineLimit(1)
        .font(.title3.bold())
        
        if !moodEntry.activities.isEmpty {
          ActivityView(activities: Array(moodEntry.activities.prefix(3)))
        }
        
        if let notes = moodEntry.observations, !notes.isEmpty {
          Text(notes)
            .lineLimit(2)
            .foregroundStyle(.black)
            .font(.caption)
            .padding(.top, 2)
        } else {
          Text("No notes")
            .foregroundStyle(.gray)
            .font(.caption)
            .padding(.top, 2)
        }
        
      }
      
      Spacer()
      
      VStack(alignment: .trailing, spacing: 5) {
        Text(formattedDate)
          .font(.caption)
          .foregroundStyle(.gray)
          .lineLimit(1)
        
        if let weatherEntryIconName = moodEntry.weatherEntry?.selectedIcon {
          Image(systemName: weatherEntryIconName)
            .font(.title2)
            .foregroundStyle(.black)
        }
        
      }
      
    }
  }
}

public struct ActivityView: View {
  let activities: [Activity]
  
  public init(activities: [Activity]) {
    self.activities = activities
  }
  
  public var body: some View {
    HStack {
      ForEach(activities) {
        Image(systemName: $0.unselectedIconName)
          .font(.caption)
          .foregroundStyle(.black)
      }
    }
  }
}

#Preview("All info") {
  MoodEntryView(moodEntry: .mockBad(), formattedDate: "3:00 pm")
    .moodSingleRow(
      accentColor: .moodGreen,
      backgroundColor: .white
    )
    .padding(.horizontal)
}

#Preview("No notes") {
  MoodEntryView(moodEntry: .mockGood(), formattedDate: "3:00 pm")
    .moodSingleRow(
      accentColor: .moodGreen,
      backgroundColor: .white
    )
    .padding(.horizontal)
}

#Preview("No weather") {
  MoodEntryView(moodEntry: .noWeather(), formattedDate: "3:00 pm")
    .moodSingleRow(
      accentColor: .moodGreen,
      backgroundColor: .white
    )
    .padding(.horizontal)
}

#Preview("Only mood") {
  MoodEntryView(moodEntry: .onlyMood(), formattedDate: "3:00 pm")
    .moodSingleRow(
      accentColor: .moodGreen,
      backgroundColor: .white
    )
    .padding(.horizontal)
}
