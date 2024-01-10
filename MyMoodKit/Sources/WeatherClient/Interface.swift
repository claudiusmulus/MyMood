//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-09.
//

import ComposableArchitecture
import Models
import Foundation

@DependencyClient
public struct WeatherClient {
    public var weather: @Sendable (_ latitude: Double, _ longitude: Double) async throws -> WeatherEntry = { _, _ in .sunny }
}

public enum WeatherClientError: Error {
    case weatherNotAvailable
}
