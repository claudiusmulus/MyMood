  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-08.
  //

import ComposableArchitecture

extension DependencyValues {
  public var locationClient: LocationClient {
    get { self[LocationClient.self] }
    set { self[LocationClient.self] = newValue }
  }
}

extension LocationClient {
  
  public static var testValue: LocationClient = LocationClient(
    authorizationStatus: unimplemented("LocationClient-authorizationStatus"),
    requestUserLocation: unimplemented("LocationClient-requestUserLocation")
  )
  public static let mockNotDetermined = LocationClient(
    authorizationStatus: { .notDetermined },
    requestUserLocation: {
      LocationGeometry(latitude: 43.7001, longitude: -79.4163)
    }
  )
  
  public static let mockAuthorizedWhenInUse = LocationClient(
    authorizationStatus: { .authorizedWhenInUse },
    requestUserLocation: {
      LocationGeometry(latitude: 43.7001, longitude: -79.4163)
    }
  )
  
  public static let mockDenied = LocationClient(
    authorizationStatus: { .denied },
    requestUserLocation: { nil }
  )
}
