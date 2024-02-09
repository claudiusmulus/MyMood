//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-08.
//

import Foundation
import ComposableArchitecture
import CoreLocation

extension LocationClient: DependencyKey {
    public static var liveValue: LocationClient {
        let locationProvider = LocationProvider()
        
        return LocationClient(
            authorizationStatus: {
                await locationProvider.authorizationStatus()
            },
            requestUserLocation: {
                try await locationProvider.requestUserLocation()?.toLocationGeometry
            }
        )
    }
}

extension CLLocation {
    var toLocationGeometry: LocationGeometry {
        LocationGeometry(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }
}

private final class LocationProvider {
    @MainActor var delegate: LocationManagerDelegate?
    @MainActor var manager: CLLocationManager?
    
    @MainActor 
    func authorizationStatus() async -> CLAuthorizationStatus {
        CLLocationManager().authorizationStatus
    }
    
    @MainActor
    func requestUserLocation() async throws -> CLLocation? {
        let stream = AsyncThrowingStream<CLLocation?, Error> { continuation in
            self.manager = CLLocationManager()
            delegate = LocationManagerDelegate(
                didChangeAuthorization: { [manager = manager] status in
                    switch status {
                    case .notDetermined:
                        manager?.requestWhenInUseAuthorization()
                    case .restricted, .denied:
                        // Checking if Location Services are enabled on the device here
                        // rather than prior to initializing the CLLocationManager
                        // should prevent UI unresponsiveness in cases where location is
                        // already shared
                        let locationServicesError: LocationClientError =
                        CLLocationManager.locationServicesEnabled()
                        ? .locationServicesDenied : .locationServicesOff
                        continuation.finish(
                            throwing: locationServicesError
                        )
                    case .authorizedAlways, .authorizedWhenInUse:
                        manager?.requestLocation()

                    @unknown default:
                        continuation.finish(
                            throwing: LocationClientError.locationServicesDenied
                        )
                    }
                },
                didUpdateLocation: { location in
                    continuation.yield(location)
                    continuation.finish()
                },
                didFailWithError: { _ in
                    continuation.finish(
                        throwing: LocationClientError.locationNotFound
                    )
                }
            )
            
            manager?.delegate = delegate
            
            // Setting the desired accuracy based on the current authorization
            let accuracyAuthorization = manager?.accuracyAuthorization
            manager?.desiredAccuracy = (accuracyAuthorization == .fullAccuracy) ? kCLLocationAccuracyKilometer : kCLLocationAccuracyReduced
            
            manager?.requestWhenInUseAuthorization()
        }
        
        for try await location in stream {
            return location
        }
        
        throw CancellationError()
    }
}

private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    let didChangeAuthorization: (CLAuthorizationStatus) -> Void
    let didUpdateLocation: (CLLocation?) -> Void
    let didFailWithError: (Error) -> Void
    init(
        didChangeAuthorization: @escaping (CLAuthorizationStatus) -> Void,
        didUpdateLocation: @escaping (CLLocation?) -> Void,
        didFailWithError: @escaping (Error) -> Void
    ) {
        self.didChangeAuthorization = didChangeAuthorization
        self.didUpdateLocation = didUpdateLocation
        self.didFailWithError = didFailWithError
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        didChangeAuthorization(manager.authorizationStatus)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocation(locations.last)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError(error)
    }
}
