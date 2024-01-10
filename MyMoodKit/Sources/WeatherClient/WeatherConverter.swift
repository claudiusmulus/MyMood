//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-09.
//

import Models

extension WeatherEntry {
    init(forecast: Forecast) {
        switch forecast.current.weatherCode {
        case 0, 1:
            self = .sunny
        case 2:
            self = .cloudy
        case 3:
            self = .overcast
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82:
            self = .rainy
        case 71, 73, 75, 77, 85, 86:
            self = .snowy
        default:
            self = .cloudy
        }
    }
}
