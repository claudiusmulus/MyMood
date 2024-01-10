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

struct WeatherWhenLocationNotDeterminedView: View {
    let store: StoreOf<MoodEntryFeature>
    
    struct ViewState: Equatable {
        @BindingViewState var weatherEntry: WeatherEntry?
        var weatherStatus: MoodEntryFeature.State.WeatherStatus
        
        init(bindingViewStore: BindingViewStore<MoodEntryFeature.State>) {
            self._weatherEntry = bindingViewStore.$moodEntry.weatherEntry
            self.weatherStatus = bindingViewStore.weatherStatus
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            switch viewStore.weatherStatus {
            case let .result(weatherEntry):
                WeatherEntryView(
                    message: weatherEntry.rawValue.capitalized,
                    iconName: weatherEntry.selectedIcon,
                    redactedCondition: false
                )
            default:
                VStack{
                    DynamicInfoActionHStack(
                        message: self.textMessage(weatherStatus: viewStore.weatherStatus),
                        actionTitle: self.buttonLabel(weatherStatus: viewStore.weatherStatus),
                        actionBackgroundColor: .black,
                        action: {
                            viewStore.send(.fetchCurrentWeather, animation: .snappy)
                        },
                        redactedCondition: viewStore.weatherStatus == .loading
                    )
                    .padding(.horizontal)
                    
                    
                    Color.black
                        .frame(height: 1)
                    
                    WeatherPicker(value: viewStore.$weatherEntry)
                        .padding(.horizontal)
                        .unredacted()
                }
                .padding(.vertical)
                .roundedBorder(borderColor: .black)
            }
        }

    }
    
    private func textMessage(weatherStatus: MoodEntryFeature.State.WeatherStatus) -> String {
        switch weatherStatus {
        case .loading:
            return .placeholder(length: 30)
        case .error:
            return "Oops! Something is not working right now."
        case .none:
            return "Automatic wheather updates?"
        default:
            return ""
        }
    }
    
    private func buttonLabel(weatherStatus: MoodEntryFeature.State.WeatherStatus) -> String {
        switch weatherStatus {
        case .loading:
            return .placeholder(length: 10)
        case .error:
            return "Retry"
        case .none:
            return "Click here"
        default:
            return ""
        }
    }
}

#Preview {
    WeatherWhenLocationNotDeterminedView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh(),
                weatherDisplay: .whenLocationNotDetermined,
                weatherStatus: .none
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .mock(.sunny, delay: 0.5)
            }
        )
    )
    .padding(.horizontal)
}
