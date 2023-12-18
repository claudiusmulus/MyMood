//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-11.
//

import Tagged
import Foundation

public enum Entry: Equatable {
    case mood(MoodEntry)
}

extension Entry: Identifiable {
    public typealias Id = Tagged<Self, UUID>
    
    public var id: Id {
        switch self {
        case let .mood(moodEntry):
            return .init(moodEntry.id.rawValue)
        }
    }
}
