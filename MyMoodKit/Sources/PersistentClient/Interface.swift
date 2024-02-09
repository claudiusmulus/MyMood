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
  public var fetchDailyEntries: (_ date: Date, _ calendar: Calendar) -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error>
  public var fetchWeeklyEntries: (_ fromDate: Date, _ toDate: Date, _ calendar: Calendar) -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error>
  public var fetchEntries: (_ date: Date?) throws -> IdentifiedArrayOf<Entry>
  public var addMoodEntry: (MoodEntry) throws -> Void
}

public enum EntryContext {
  case all
  case date(_ date: Date, calendar: Calendar)
  case range(from: Date, to: Date, calendar: Calendar)
}
