//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-10.
//

import SwiftUI
import ComposableArchitecture
import Models
import UIComponents

struct WeatherPathView: View {
    let store: StoreOf<MoodEntryFeature>
    
    struct ViewState: Equatable {
        var weatherDisplay: MoodEntryFeature.State.WeatherDisplay
        
        init(_ state: MoodEntryFeature.State) {
            self.weatherDisplay = state.weatherDisplay
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                HStack {
                    Text("Weather")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                switch viewStore.weatherDisplay {
                case .whenLocationAuthorized:
                    WeatherWhenLocationAuthorizedView(store: self.store)
                case .whenLocationDenied:
                    WeatherWhenLocationDeniedView(store: self.store)
                case .whenLocationNotDetermined:
                    WeatherWhenLocationNotDeterminedView(store: self.store)
                }
            }
        }
    }
}

#Preview("Location not determined") {
    WeatherPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockNotDetermined
                dependecyValues.weatherClient = .mock(.snowy, delay: 0.5)
            }
        )
    
    )
    .padding(.horizontal)
}

#Preview("Location authorized loading") {
    WeatherPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh(),
                weatherDisplay: .whenLocationAuthorized,
                weatherStatus: .loading
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .failure(delay: 1.0)
            }
        )
    
    )
    .padding(.horizontal)
}

#Preview("Location authorized cloudy") {
    WeatherPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh(),
                weatherDisplay: .whenLocationAuthorized,
                weatherStatus: .result(.cloudy)
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .failure(delay: 1.0)
            }
        )
    
    )
    .padding(.horizontal)
}

#Preview("Location authorized error") {
    WeatherPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh(),
                weatherDisplay: .whenLocationAuthorized,
                weatherStatus: .error(message: "Something went wrong")
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .failure(delay: 1.0)
            }
        )
    
    )
    .padding(.horizontal)
}

#Preview("Location denied") {
    WeatherPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh(),
                weatherDisplay: .whenLocationDenied
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockDenied
                dependecyValues.weatherClient = .failure(delay: 1.0)
            }
        )
    
    )
    .padding(.horizontal)
}
