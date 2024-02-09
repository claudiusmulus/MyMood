  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2023-12-11.
  //

import Foundation
import Tagged
import SwiftUI
import IdentifiedCollections
import Dependencies
import CoreData

public struct MoodEntry: Equatable, Identifiable {
  public typealias Id = Tagged<Self, UUID>
  
  public let id: Id
  public var date: Date
  public var colorCode: Color.Resolved
  public var moodScale: Double
  public var mood: Mood
  public var activities: IdentifiedArrayOf<Activity> = []
  public var quickNote: String
  public var observations: String?
  public var weatherEntry: WeatherEntry?
  public var managedObjectId: NSManagedObjectID?
    
  public init() {
    @Dependency(\.uuid) var uuid
    @Dependency(\.date.now) var now
    self.id = .init(uuid())
    self.date = now
    self.colorCode = .init(red: 1, green: 0.81, blue: 0.29, opacity: 1)
    self.moodScale = 0.5
    self.mood = .okay
    self.activities = []
    self.quickNote = ""
    self.observations = nil
    self.weatherEntry = nil
    self.managedObjectId = nil
  }
  
  public init(
    id: Id,
    date: Date,
    colorCode: Color.Resolved,
    moodScale: Double,
    mood: Mood,
    activities: IdentifiedArrayOf<Activity>,
    quickNote: String,
    observations: String?,
    weatherEntry: WeatherEntry? = nil,
    managedObjectId: NSManagedObjectID? = nil
  ) {
    self.id = id
    self.date = date
    self.colorCode = colorCode
    self.moodScale = moodScale
    self.mood = mood
    self.activities = activities
    self.quickNote = quickNote
    self.observations = observations
    self.weatherEntry = weatherEntry
    self.managedObjectId = managedObjectId
  }
}
