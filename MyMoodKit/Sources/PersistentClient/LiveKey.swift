//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-29.
//

import Foundation
import ComposableArchitecture
import DependenciesAdditions
import Models

extension PersistentClient: DependencyKey {
  public static var liveValue: PersistentClient {
    self.coreData
  }
  
  public static var testValue: PersistentClient {
    PersistentClient(
      fetchEntries: { _ in
        unimplemented("PersistentClient.fetchEntries")
      }, 
      addMoodEntry: { _ in
        unimplemented("PersistentClient.addMoodEntry")
      }
    )
  }
  
}

extension PersistentClient {
  public static var coreData: PersistentClient {
    
    let coreDataPersistentClient = CoreDataPersistentClient(persistentContainer: PersistentContainer(bundle: .module))
    
    return PersistentClient(
      fetchEntries: coreDataPersistentClient.fetchEntries(by:),
      addMoodEntry: coreDataPersistentClient.addMoodEntry
    )
  }
}
