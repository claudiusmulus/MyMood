//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-29.
//

import Foundation
import CoreData

@objc(MoodEntryObject)
public class MoodEntryObject: NSManagedObject, Identifiable {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<MoodEntryObject> {
    return NSFetchRequest<MoodEntryObject>(entityName: "MoodEntryObject")
  }
  
  @NSManaged public var date: Date
  @NSManaged public var moodScale: Double
  @NSManaged public var mood: String
  @NSManaged public var notes: String?
  @NSManaged public var weatherEntry: String?
  @NSManaged public var colorRed: Float
  @NSManaged public var colorGreen: Float
  @NSManaged public var colorBlue: Float
  @NSManaged public var colorOpacity: Float
  @NSManaged public var activities: [String]?
}
