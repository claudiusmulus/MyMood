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
  
  func groupedBy(
    dateComponents: Set<Calendar.Component>,
    sectionDateComponents: Set<Calendar.Component>,
    calendar: Calendar,
    formatter: @escaping (Date) -> String
  ) -> [Date: [Date: EntryListFeature.State.SectionEntryValue]] {
    
    let dict: [Date: [Date: EntryListFeature.State.SectionEntryValue]] = [:]
    
    return self.reduce(into: dict) { partialResult, entry in
      let entryDateComponents = calendar.dateComponents(dateComponents, from: entry.date)
      let entrySectionDateComponents = calendar.dateComponents(sectionDateComponents, from: entry.date)
      
      guard let date = calendar.date(from: entryDateComponents),
            let sectionDate = calendar.date(from: entrySectionDateComponents) else {
        return
      }
      
      var current = partialResult[date] ?? [:]
      
      let currentSection = current[sectionDate]
        .appendEntry(entry, date: sectionDate, formatter: formatter)
      
      current[sectionDate] = currentSection
      
      partialResult[date] = current
      
    }
  }
}

extension Dictionary where Key == Date, Value == Dictionary<Date, EntryListFeature.State.SectionEntryValue> {
  mutating func appendEntry(
    _ entry: Entry,
    calendar: Calendar,
    formatter: @escaping (Date) -> String
  ) {
    let entryDateComponents = calendar.dateComponents([.month, .year], from: entry.date)
    let entrySectionDateComponents = calendar.dateComponents([.day, .month, .year], from: entry.date)
    
    guard let date = calendar.date(from: entryDateComponents),
          let sectionDate = calendar.date(from: entrySectionDateComponents) else {
      return
    }
    
    let newEntryDict = self[date].appendEntry(entry: entry, date: sectionDate, formatter: formatter)
    
    self[date] = newEntryDict
  }
}

extension Optional where Wrapped == Dictionary<Date, EntryListFeature.State.SectionEntryValue> {
  func appendEntry(
    entry: Entry,
    date: Date,
    formatter: @escaping (Date) -> String
  ) -> Dictionary<Date, EntryListFeature.State.SectionEntryValue> {
    switch self {
      case .none:
        let entries = IdentifiedArray(uniqueElements: [entry])
        return [date: .init(entries: .init(uniqueElements: entries), formattedDate: formatter(date), averageColor: entries.moodAverageColor)]
      case let .some(wrappedValue):
        let currentSection = wrappedValue[date].appendEntry(entry, date: date, formatter: formatter)
        return [date: currentSection]
    }
  }
}

extension Optional where Wrapped == EntryListFeature.State.SectionEntryValue {
  func appendEntry(_ entry: Entry, date: Date, formatter: @escaping (Date) -> String) -> EntryListFeature.State.SectionEntryValue {
    switch self {
      case .none:
        let entries = IdentifiedArrayOf(uniqueElements: [entry])
        return EntryListFeature.State.SectionEntryValue(
          entries: entries,
          formattedDate: formatter(date),
          averageColor: entries.moodAverageColor
        )
      case let .some(wrappedValue):
        var currentEntries = wrappedValue.entries
        currentEntries.append(entry)
        return EntryListFeature.State.SectionEntryValue(
          entries: currentEntries,
          formattedDate: wrappedValue.formattedDate,
          averageColor: currentEntries.moodAverageColor
        )
    }
  }
}
