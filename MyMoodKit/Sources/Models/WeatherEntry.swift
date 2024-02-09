//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-08.
//

import Foundation

public enum WeatherEntry: String, CaseIterable, Codable, Equatable, RawRepresentable {
    case sunny
    case cloudy
    case overcast
    case rainy
    case snowy
    
    public var id: String {
        self.rawValue
    }
}

public extension WeatherEntry {
    var unselectedIcon: String {
        switch self {
        case .sunny:
            return "sun.max"
        case .cloudy:
            return "cloud.sun"
        case .overcast:
            return "cloud"
        case .rainy:
            return "cloud.rain"
        case .snowy:
            return "cloud.snow"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .sunny:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.sun.fill"
        case .overcast:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .snowy:
            return "cloud.snow.fill"
        }
    }
}
