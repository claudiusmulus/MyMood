//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-11.
//

import Tagged
import SwiftUI

public enum Activity: Codable, Equatable {
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
    case other(String)
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
        case let .other(otherActivity):
            return .init("other-" + otherActivity)
        }
    }
}

extension Activity {
    public var icon: Image {
        switch self {
        case .work:
            return Image(systemName: "briefcase")
        case .family:
            return Image(systemName: "house")
        case .friends:
            return Image(systemName: "person")
        case .school:
            return Image(systemName: "graduationcap")
        case .relationship:
            return Image(systemName: "person.2")
        case .traveling:
            return Image(systemName: "airplane")
        case .food:
            return Image(systemName: "fork.knife")
        case .exercise:
            return Image(systemName: "figure.run")
        case .health:
            return Image(systemName: "heart")
        case .hobbies:
            return Image(systemName: "star.circle")
        case .gaming:
            return Image(systemName: "gamecontroller")
        case .weather:
            return Image(systemName: "sun.rain")
        case .shopping:
            return Image(systemName: "bag")
        case .sleep:
            return Image(systemName: "bed.double")
        case .music:
            return Image(systemName: "headphones")
        case .relaxing:
            return Image(systemName: "sofa")
        case .other:
            return Image(systemName: "pencil")
        }
    }
}
