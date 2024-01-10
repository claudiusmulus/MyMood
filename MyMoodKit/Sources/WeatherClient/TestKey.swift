//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-09.
//

import ComposableArchitecture
import Foundation
import Models

extension DependencyValues {
    public var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}

extension WeatherClient {
    public static let mockSunny: WeatherClient = WeatherClient(weather: { _, _ in .sunny })
    public static func mock(_ response: WeatherEntry, delay: CGFloat = 0) -> WeatherClient {
        WeatherClient(weather: { _, _ in
            if delay > 0 {
                try await Task.sleep(for: .seconds(delay))
            }
            return response
        })
    }
    
    public static func failure(delay: CGFloat = 0) -> WeatherClient {
        mock(.failure(WeatherClientError.weatherNotAvailable), delay: delay)
    }
     
    public static func mock(_ result: Result<WeatherEntry, Error>, delay: CGFloat = 0) -> WeatherClient {
        WeatherClient(weather: { _, _ in
            if delay > 0 {
                try await Task.sleep(for: .seconds(delay))
            }
            switch result {
            case let .success(success):
                return success
            case let .failure(error):
                throw error
            }
        })
    }
}
