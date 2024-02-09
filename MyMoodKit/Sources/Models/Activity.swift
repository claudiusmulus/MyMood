//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-11.
//

import Tagged
import SwiftUI

public enum Activity: String, Codable, Equatable, RawRepresentable {
    case work
    case family
    case friends
    case school
    case relationship
    case traveling
    case food
    case exercise
    case health
    case hobbies
    case gaming
    case weather
    case shopping
    case sleep
    case music
    case relaxing
    case other
}

extension Activity: CaseIterable {
    public static var allCases: [Activity] = [
        .family,
        .friends,
        .work,
        .school,
        .relationship,
        .traveling,
        .food,
        .exercise,
        .health,
        .hobbies,
        .gaming,
        .weather,
        .shopping,
        .sleep,
        .music,
        .relaxing,
        .other
    ]
}

extension Activity: Identifiable {
    public typealias Id = Tagged<Self, String>
    
    public var id: Id {
        switch self {
        case .work:
            return .init("work")
        case .family:
            return .init("family")
        case .friends:
            return .init("friends")
        case .school:
            return .init("school")
        case .relationship:
            return .init("relationship")
        case .traveling:
            return .init("traveling")
        case .food:
            return .init("food")
        case .exercise:
            return .init("exercise")
        case .health:
            return .init("health")
        case .hobbies:
            return .init("hobbies")
        case .gaming:
            return .init("gaming")
        case .weather:
            return .init("weather")
        case .shopping:
            return .init("shopping")
        case .sleep:
            return .init("sleep")
        case .music:
            return .init("music")
        case .relaxing:
            return .init("relaxing")
        case .other:
            return .init("other")
        }
    }
}

extension Activity {
    
    public var unselectedIconName: String {
        switch self {
        case .work:
            return "briefcase"
        case .family:
            return "house"
        case .friends:
            return "person"
        case .school:
            return "graduationcap"
        case .relationship:
            return "person.2"
        case .traveling:
            return "airplane"
        case .food:
            return "fork.knife"
        case .exercise:
            return "figure.run"
        case .health:
            return "heart"
        case .hobbies:
            return "star.circle"
        case .gaming:
            return "gamecontroller"
        case .weather:
            return "sun.rain"
        case .shopping:
            return "bag"
        case .sleep:
            return "bed.double"
        case .music:
            return "headphones"
        case .relaxing:
            return "sofa"
        case .other:
            return "pencil"
        }
    }
    
    public var selectedIconName: String {
        switch self {
        case .work:
            return "briefcase.fill"
        case .family:
            return "house.fill"
        case .friends:
            return "person.fill"
        case .school:
            return "graduationcap.fill"
        case .relationship:
            return "person.2.fill"
        case .traveling:
            return "airplane"
        case .food:
            return "fork.knife"
        case .exercise:
            return "figure.run"
        case .health:
            return "heart.fill"
        case .hobbies:
            return "star.circle.fill"
        case .gaming:
            return "gamecontroller.fill"
        case .weather:
            return "sun.rain.fill"
        case .shopping:
            return "bag.fill"
        case .sleep:
            return "bed.double.fill"
        case .music:
            return "headphones"
        case .relaxing:
            return "sofa.fill"
        case .other:
            return "pencil"
        }
    }
    
    public var title: String {
        switch self {
        case .work:
            return "Work"
        case .family:
            return "Family"
        case .friends:
            return "Friends"
        case .school:
            return "School"
        case .relationship:
            return "Relationship"
        case .traveling:
            return "Travel"
        case .food:
            return "Food"
        case .exercise:
            return "Exercise"
        case .health:
            return "Health"
        case .hobbies:
            return "Hobbies"
        case .gaming:
            return "Gaming"
        case .weather:
            return "Weather"
        case .shopping:
            return "Shopping"
        case .sleep:
            return "Sleep"
        case .music:
            return "Music"
        case .relaxing:
            return "Relaxing"
        case .other:
            return "Other"
        }
    }
}
