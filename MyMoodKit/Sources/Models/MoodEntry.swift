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

public struct MoodEntry: Codable, Equatable, Identifiable {
    public typealias Id = Tagged<Self, UUID>
    
    public let id: Id
    public var date: Date
    public var colorCode: Color.Resolved
    public var moodScale: Double
    public var mood: Mood
    public var activities: IdentifiedArrayOf<Activity> = []
    public var quickNote: String
    public var observations: String
    public var weatherEntry: WeatherEntry?
}
