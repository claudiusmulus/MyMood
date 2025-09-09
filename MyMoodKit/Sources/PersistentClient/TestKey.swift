//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-29.
//

import ComposableArchitecture
import Models
import Foundation

extension DependencyValues {
  public var persistentClient: PersistentClient {
    get { self[PersistentClient.self] }
    set { self[PersistentClient.self] = newValue }
  }
}

extension PersistentClient {
  static public var previewValue: PersistentClient {
    PersistentClient(
      fetchDailyEntries: { _, _ in
        return AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> { continuation in
          continuation.yield(.mockMood())
          continuation.finish()
        }
      },
      fetchWeeklyEntries: { _, _, _ in
        return AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> { continuation in
          continuation.yield([Date(timeIntervalSince1970: 1_234_567_890): .mockMood()])
          continuation.finish()
        }
      },
      fetchEntriesByMonth: {
        return AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> { continuation in
          continuation.yield([Date(timeIntervalSince1970: 1_234_567_890): .mockMood()])
          continuation.finish()
        }
      },
      addMoodEntry: { _ in }
    )
  }
}
