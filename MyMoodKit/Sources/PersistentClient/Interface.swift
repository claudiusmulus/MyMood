//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-29.
//

import ComposableArchitecture
import Models
import Foundation

public struct PersistentClient {
  public var fetchDailyEntries: (_ date: Date, _ calendar: Calendar) async -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error>
  public var fetchWeeklyEntries: (_ fromDate: Date, _ toDate: Date, _ calendar: Calendar) async -> AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error>
  public var fetchEntriesByMonth: () async -> AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error>
  public var addMoodEntry: (MoodEntry) throws -> Void
}

public enum EntryContext {
  case all
  case date(_ date: Date, calendar: Calendar)
  case range(from: Date, to: Date, calendar: Calendar)
}
