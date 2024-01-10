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

struct WeatherWhenLocationDeniedView: View {
    let store: StoreOf<MoodEntryFeature>
    
    struct ViewState: Equatable {
        @BindingViewState var weatherEntry: WeatherEntry?
        
        init(bindingViewStore: BindingViewStore<MoodEntryFeature.State>) {
            self._weatherEntry = bindingViewStore.$moodEntry.weatherEntry
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack{
                DynamicInfoActionHStack(
                    message: "Do you prefer automatic wheather updates?",
                    actionTitle: "Settings",
                    actionBackgroundColor: .black,
                    action: {
                        viewStore.send(.goToSettingsButtonTapped)
                    },
                    redactedCondition: false
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
    WeatherWhenLocationDeniedView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockDenied
                dependecyValues.weatherClient = .mock(.sunny, delay: 0.5)
            }
        )
    )
    .padding(.horizontal)
}
