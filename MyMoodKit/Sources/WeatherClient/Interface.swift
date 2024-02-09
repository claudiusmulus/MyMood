  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-09.
  //

import ComposableArchitecture
import Models
import Foundation

public struct WeatherClient {
  public var weather: @Sendable (_ latitude: Double, _ longitude: Double) async throws -> WeatherEntry
}

public enum WeatherClientError: Error {
  case weatherNotAvailable
}
