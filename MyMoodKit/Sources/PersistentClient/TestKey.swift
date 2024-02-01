//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-29.
//

import ComposableArchitecture

extension DependencyValues {
  public var persistentClient: PersistentClient {
    get { self[PersistentClient.self] }
    set { self[PersistentClient.self] = newValue }
  }
}

extension PersistentClient {
  static public var previewValue: PersistentClient {
    PersistentClient(
      fetchEntries: { _ in .mockModGood() },
      addMoodEntry: { _ in }
    )
  }
}
