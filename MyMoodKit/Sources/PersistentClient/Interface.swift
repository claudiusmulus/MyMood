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
  public var fetchEntries: (_ date: Date?) throws -> IdentifiedArrayOf<Entry>
  public var addMoodEntry: (MoodEntry) throws -> Void
}
