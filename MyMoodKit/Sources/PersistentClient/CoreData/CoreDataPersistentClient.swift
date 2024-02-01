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
import CoreData
import SwiftUI
import Tagged


final class CoreDataPersistentClient {

  let persistentContainer: PersistentContainer

  init(persistentContainer: PersistentContainer) {
    self.persistentContainer = persistentContainer
  }
  
  func fetchEntries(by date: Date?) throws -> IdentifiedArrayOf<Entry> {
    
    let request = MoodEntryObject.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryObject.date, ascending: false)]
    
    if let requestedDate = date {
      request.predicate = NSPredicate(
        format: "%K == %@",
        #keyPath(MoodEntryObject.date),
        requestedDate as NSDate
      )
    }
    
    do {
      let moodEntryObjects = try self.persistentContainer.viewContext.fetch(request)
      
      let entries: [Entry] = moodEntryObjects.map {
        .mood(MoodEntry(object: $0))
      }
      
      return IdentifiedArray(uniqueElements: entries)
      
    } catch {
      // TODO.Handle errors
    }
    
    return []
  }
  
  func addMoodEntry(_ moodEntry: MoodEntry) throws -> Void {
   
    let moodEntryObject = MoodEntryObject(context: self.persistentContainer.viewContext)
    
    moodEntryObject.date = moodEntry.date
    moodEntryObject.colorRed = moodEntry.colorCode.red
    moodEntryObject.colorBlue = moodEntry.colorCode.blue
    moodEntryObject.colorGreen = moodEntry.colorCode.green
    moodEntryObject.colorOpacity = moodEntry.colorCode.opacity
    moodEntryObject.moodScale = moodEntry.moodScale
    moodEntryObject.mood = moodEntry.mood.rawValue
    moodEntryObject.notes = moodEntry.observations
    moodEntryObject.weatherEntry = moodEntry.weatherEntry?.rawValue
    moodEntryObject.activities = moodEntry.activities.elements.map(\.rawValue)
    
    do {
      try persistentContainer.viewContext.save()
    } catch {
      persistentContainer.viewContext.rollback()
      // Handle error properly
    }
  }
}

extension MoodEntry {
  init(object: MoodEntryObject) {
    @Dependency(\.uuid) var uuid
    let color = Color.Resolved(
      red: object.colorRed,
      green: object.colorGreen,
      blue: object.colorBlue,
      opacity: object.colorOpacity
    )
    
    let activities: [Activity] = object
      .activities?
      .compactMap {
        Activity.init(rawValue: $0)
    } ?? []
    
    self.init(
      id: .init(uuid()),
      date: object.date,
      colorCode: color,
      moodScale: object.moodScale,
      mood: Mood(rawValue: object.mood) ?? .okay,
      activities: IdentifiedArray(uniqueElements: activities),
      quickNote: "",
      observations: object.notes,
      weatherEntry: WeatherEntry(string: object.weatherEntry),
      managedObjectId: object.objectID
    )
  }
}

extension WeatherEntry {
  init?(string: String?) {
    guard let rawValue = string else {
      return nil
    }
    self.init(rawValue: rawValue)
  }
}

