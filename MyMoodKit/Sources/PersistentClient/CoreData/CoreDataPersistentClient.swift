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

enum CoreDataError: Error {
  case notAvailable
}

final class CoreDataPersistentClient {

  let persistentContainer: PersistentContainer
  
  private(set) var fetchedDailyEntriesResultController: NSFetchedResultsController<MoodEntryObject>?
  private(set) var fetchedWeeklyEntriesResultController: NSFetchedResultsController<MoodEntryObject>?
  private(set) var fetchedMonthlyEntriesResultController: NSFetchedResultsController<MoodEntryObject>?

  init(persistentContainer: PersistentContainer) {
    self.persistentContainer = persistentContainer
  }
  
  func fetchDailyEntries(date: Date, calendar: Calendar) async -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> {
    await self.persistentContainer.viewContext.perform {
      let stream = AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> { [weak self] continuation in
        guard let self = self else {
          continuation.finish(throwing: CoreDataError.notAvailable)
          return
        }
        let request = MoodEntryObject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryObject.date, ascending: false)]
        
        request.predicate = NSPredicate(
          format: "%K >= %@",
          #keyPath(MoodEntryObject.date),
          calendar.startOfDay(for: date) as CVarArg
        )
        
        let fetchedResultController = NSFetchedResultsController<MoodEntryObject>(
          fetchRequest: request,
          managedObjectContext: persistentContainer.viewContext,
          sectionNameKeyPath: nil,
          cacheName: nil
        )
        
        fetchedDailyEntriesResultController = fetchedResultController
        
        let delegate = MoodEntryObjectRequestDelegate(continuation: continuation)
        
        fetchedResultController.delegate = delegate
        
        continuation.onTermination = { [weak self] _ in
          self?.fetchedDailyEntriesResultController = nil
          _ = delegate
        }
        
        do {
          try fetchedResultController.performFetch()
          let moodEntryObjects = fetchedResultController.fetchedObjects ?? []
          let entries: [Entry] = moodEntryObjects.map {
            .mood(MoodEntry(object: $0))
          }
          continuation.yield(IdentifiedArray(uniqueElements: entries))
        } catch {
          continuation.finish(throwing: error)
        }
        
      }
      
      return stream
    }
  }
  
  func fetchWeeklyEntries(from fromDate: Date, to toDate: Date, calendar: Calendar) async -> AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> {

    await self.persistentContainer.viewContext.perform {
      let stream = AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> { [weak self] continuation in
        guard let self else {
          continuation.finish(throwing: CoreDataError.notAvailable)
          return
        }
        
        let request = MoodEntryObject.fetchRequest()
        request.sortDescriptors = [
          NSSortDescriptor(keyPath: \MoodEntryObject.sortDailyDate, ascending: false),
          NSSortDescriptor(keyPath: \MoodEntryObject.date, ascending: false)
        ]
        
        request.predicate = NSPredicate(
          format: "%K >= %@ AND %K <= %@",
          #keyPath(MoodEntryObject.date),
          calendar.startOfDay(for: fromDate) as CVarArg,
          #keyPath(MoodEntryObject.date),
          calendar.startOfDay(for: toDate) as CVarArg
        )
        
        let fetchedResultController = NSFetchedResultsController<MoodEntryObject>(
          fetchRequest: request,
          managedObjectContext: persistentContainer.viewContext,
          sectionNameKeyPath: #keyPath(MoodEntryObject.sortDailyDate),
          cacheName: nil
        )
        
        fetchedWeeklyEntriesResultController = fetchedResultController
        
        let delegate = MoodEntryObjectSectionRequestDelegate(continuation: continuation)
        
        fetchedResultController.delegate = delegate
        
        continuation.onTermination = { [weak self] _ in
          self?.fetchedWeeklyEntriesResultController = nil
          _ = delegate
        }
        
        do {
          try fetchedResultController.performFetch()
          let sections = fetchedResultController.sections ?? []
          
          continuation.yield(sections.groupEntries(by: \.sortDailyDate))
        } catch {
          continuation.finish(throwing: error)
        }
        
      }
      return stream
    }
  }
  
  func fetchEntriesGroupedByMonth() async -> AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> {
    
    await self.persistentContainer.viewContext.perform {
      let stream = AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> { [weak self] continuation in
        guard let self else {
          continuation.finish(throwing: CoreDataError.notAvailable)
          return
        }
        
        let request = MoodEntryObject.fetchRequest()
        request.sortDescriptors = [
          NSSortDescriptor(keyPath: \MoodEntryObject.sortMonthlyDate, ascending: false),
          NSSortDescriptor(keyPath: \MoodEntryObject.date, ascending: false)
        ]
        
        let fetchedResultController = NSFetchedResultsController<MoodEntryObject>(
          fetchRequest: request,
          managedObjectContext: persistentContainer.viewContext,
          sectionNameKeyPath: #keyPath(MoodEntryObject.sortMonthlyDate),
          cacheName: nil
        )
        
        fetchedMonthlyEntriesResultController = fetchedResultController
        
        let delegate = MoodEntryObjectMonthSectionRequestDelegate(continuation: continuation)
        
        fetchedResultController.delegate = delegate
        
        continuation.onTermination = { [weak self] _ in
          self?.fetchedMonthlyEntriesResultController = nil
          _ = delegate
        }
        
        do {
          try fetchedResultController.performFetch()
          let sections = fetchedResultController.sections ?? []
          
          continuation.yield(sections.groupEntries(by: \.sortMonthlyDate))
        } catch {
          continuation.finish(throwing: error)
        }
        
      }
      return stream
    }
  }
  
  func addMoodEntry(_ moodEntry: MoodEntry) throws -> Void {
    
    self.persistentContainer.viewContext.performAndWait { [weak self] in
      guard let self else {
        return
      }
      let moodEntryObject = MoodEntryObject(context: persistentContainer.viewContext)
      
      moodEntryObject.date = moodEntry.date
      moodEntryObject.sortDailyDate = moodEntry.sortingDayDate
      moodEntryObject.sortMonthlyDate = moodEntry.sortingMonthDate
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
}

private class MoodEntryObjectRequestDelegate: NSObject, NSFetchedResultsControllerDelegate {
  let continuation: AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error>.Continuation
  
  init(continuation: AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error>.Continuation) {
    self.continuation = continuation
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    let moodEntryObjects = controller.fetchedObjects as? [MoodEntryObject] ?? []
    let entries: [Entry] = moodEntryObjects.map {
      .mood(MoodEntry(object: $0))
    }
    self.continuation.yield(IdentifiedArray(uniqueElements: entries))
  }
}

private class MoodEntryObjectSectionRequestDelegate: NSObject, NSFetchedResultsControllerDelegate {
  let continuation: AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error>.Continuation
  
  init(continuation: AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error>.Continuation) {
    self.continuation = continuation
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    let sections = controller.sections ?? []
    
    continuation.yield(sections.groupEntries(by: \.sortDailyDate))
  }
}

private class MoodEntryObjectMonthSectionRequestDelegate: NSObject, NSFetchedResultsControllerDelegate {
  let continuation: AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error>.Continuation
  
  init(continuation: AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error>.Continuation) {
    self.continuation = continuation
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    let sections = controller.sections ?? []
    
    continuation.yield(sections.groupEntries(by: \.sortMonthlyDate))
  }
}

extension Array where Element == NSFetchedResultsSectionInfo {
  func groupEntries(by dateKeyPath: KeyPath<MoodEntryObject, Date>) -> [Date: IdentifiedArrayOf<Entry>] {
    self.reduce(into: [Date: IdentifiedArrayOf<Entry>]()) { partialResult, sectionInfo in
      
      let moodEntryObjects = sectionInfo.objects as? [MoodEntryObject] ?? []
      guard moodEntryObjects.count > 0 else {
        return
      }
      let groupingDate = moodEntryObjects[0][keyPath: dateKeyPath]
      let entries: [Entry] = moodEntryObjects.map {
        .mood(MoodEntry(object: $0))
      }
      partialResult[groupingDate] = IdentifiedArray(uniqueElements: entries)
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
      sortingDayDate: object.sortDailyDate,
      sortingMonthDate: object.sortMonthlyDate,
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

