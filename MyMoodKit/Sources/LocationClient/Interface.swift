  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-08.
  //

import ComposableArchitecture
import CoreLocation

public struct LocationClient {
  public var authorizationStatus: @Sendable () async -> CLAuthorizationStatus
  public var requestUserLocation: @Sendable () async throws -> LocationGeometry?
}

public enum LocationClientError: Error {
  case locationServicesDenied
  case locationServicesOff
  case locationNotFound
  case unknown
}

public struct LocationGeometry {
  public var latitude: CLLocationDegrees
  public var longitude: CLLocationDegrees
  
  public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    self.latitude = latitude
    self.longitude = longitude
  }
}
