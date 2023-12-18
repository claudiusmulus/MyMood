//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-12.
//

import Models

extension Mood {
    public var title: String {
        switch self {
        case .awesome:
            return "Awesome"
        case .good:
            return "Good"
        case .okay:
            return "Okaish"
        case .bad:
            return "Kind of bad"
        case .terrible:
            return "Really terrible"
        }
    }
}
