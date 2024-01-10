//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-09.
//

import ComposableArchitecture
import Foundation
import Models

extension WeatherClient: DependencyKey {
    public static var liveValue: WeatherClient {
        WeatherClient { latitude, longitude in
            var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
            components.queryItems = [
              URLQueryItem(name: "latitude", value: "\(latitude)"),
              URLQueryItem(name: "longitude", value: "\(longitude)"),
              URLQueryItem(name: "current", value: "weather_code"),
              URLQueryItem(name: "timezone", value: TimeZone.autoupdatingCurrent.identifier),
            ]
            
            do {
                let (data, _) = try await URLSession.shared.data(from: components.url!)
                let forecast =  try jsonDecoder.decode(Forecast.self, from: data)
                
                return WeatherEntry(forecast: forecast)
            } catch {
                throw WeatherClientError.weatherNotAvailable
            }
        }
    }
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .iso8601)
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()

struct Forecast: Codable, Equatable {
    
    var current: Current
    
    struct Current: Codable, Equatable {
        var weatherCode: Int
    }
}

extension Forecast {
  private enum CodingKeys: String, CodingKey {
    case current
  }
}

extension Forecast.Current {
  private enum CodingKeys: String, CodingKey {
    case weatherCode = "weather_code"
  }
}
