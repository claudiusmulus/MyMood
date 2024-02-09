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

  init(persistentContainer: PersistentContainer) {
    self.persistentContainer = persistentContainer
  }
  
  func fetchDailyEntries(date: Date, calendar: Calendar) -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> {
    fetchEntries(
      ofFilterRequest: {
        $0.predicate = NSPredicate(
          format: "%K >= %@",
          #keyPath(MoodEntryObject.date),
          calendar.startOfDay(for: date) as CVarArg
        )
      }, 
      onStoreFetcher: { [weak self] fetcher in
        guard let strongSelf = self else {
          return
        }
        strongSelf.fetchedDailyEntriesResultController = fetcher
      },
      onTermination: { [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.fetchedDailyEntriesResultController = nil
        
      }
    )
  }
  
  func fetchWeeklyEntries(from fromDate: Date, to toDate: Date, calendar: Calendar) -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> {
    fetchEntries(
      ofFilterRequest: {
        $0.predicate = NSPredicate(
          format: "%K >= %@ AND %K <= %@",
          #keyPath(MoodEntryObject.date),
          calendar.startOfDay(for: fromDate) as CVarArg,
          #keyPath(MoodEntryObject.date),
          calendar.startOfDay(for: toDate) as CVarArg
        )
      },
      onStoreFetcher: { [weak self] fetcher in
        guard let strongSelf = self else {
          return
        }
        strongSelf.fetchedWeeklyEntriesResultController = fetcher
      },
      onTermination: { [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.fetchedWeeklyEntriesResultController = nil
        
      }
    )
  }
  
  private func fetchEntries(
    ofFilterRequest: (NSFetchRequest<MoodEntryObject>) -> Void,
    onStoreFetcher: (NSFetchedResultsController<MoodEntryObject>) -> Void,
    onTermination: @escaping () -> Void
  ) -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> {
    let stream = AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> { [weak self] continuation in
      guard let strongSelf = self else {
        continuation.finish(throwing: CoreDataError.notAvailable)
        return
      }
      let request = MoodEntryObject.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryObject.date, ascending: false)]
      
      ofFilterRequest(request)
      
      let fetchedResultController = NSFetchedResultsController<MoodEntryObject>(
        fetchRequest: request,
        managedObjectContext: strongSelf.persistentContainer.viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil
      )
      
      onStoreFetcher(fetchedResultController)
      
      let delegate = MoodEntryObjectRequestDelegate(continuation: continuation)
      
      fetchedResultController.delegate = delegate
      
      continuation.onTermination = { _ in
        onTermination()
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
  
//  func fetchEntries(context: EntryContext) -> AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> {
//    let stream = AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> { [weak self] continuation in
//      guard let strongSelf = self else {
//        continuation.finish(throwing: CoreDataError.notAvailable)
//        return
//      }
//      let request = MoodEntryObject.fetchRequest()
//      request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntryObject.date, ascending: false)]
//      
//      switch context {
//        case .all:
//          break
//        case let .date(date, calendar):
//          request.predicate = NSPredicate(
//            format: "%K >= %@",
//            #keyPath(MoodEntryObject.date),
//            calendar.startOfDay(for: date) as CVarArg
//          )
//        case let .range(from, to, calendar):
//          request.predicate = NSPredicate(
//            format: "%K >= %@ AND %K <= %@",
//            #keyPath(MoodEntryObject.date),
//            calendar.startOfDay(for: from) as CVarArg,
//            #keyPath(MoodEntryObject.date),
//            calendar.startOfDay(for: to) as CVarArg
//          )
//      }
//      
//      let fetchedResultController = NSFetchedResultsController<MoodEntryObject>(fetchRequest: request, managedObjectContext: strongSelf.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//      strongSelf.fetchedResultController = fetchedResultController
//      let delegate = MoodEntryObjectRequestDelegate(continuation: continuation)
//      
//      fetchedResultController.delegate = delegate
//      
//      continuation.onTermination = { _ in
//        strongSelf.fetchedResultController = nil
//        _ = delegate
//      }
//      
//      do {
//        try fetchedResultController.performFetch()
//        let moodEntryObjects = fetchedResultController.fetchedObjects ?? []
//        let entries: [Entry] = moodEntryObjects.map {
//          .mood(MoodEntry(object: $0))
//        }
//        continuation.yield(IdentifiedArray(uniqueElements: entries))
//      } catch {
//        continuation.finish(throwing: error)
//      }
//
//    }
//    
//    return stream
//  }
  
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
  
//  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
//    guard diff.insertions.count > 0 || diff.removals.count > 0 else {
//      return
//    }
//    let moodEntryObjects = controller.fetchedObjects as? [MoodEntryObject] ?? []
//    let entries: [Entry] = moodEntryObjects.map {
//      .mood(MoodEntry(object: $0))
//    }
//    self.continuation.yield(IdentifiedArray(uniqueElements: entries))
//  }
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

