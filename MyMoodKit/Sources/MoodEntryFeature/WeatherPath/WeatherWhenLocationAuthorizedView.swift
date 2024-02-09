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

struct WeatherWhenLocationAuthorizedView: View {
  let store: StoreOf<ExtraContentPathFeature>
  
  struct ViewState: Equatable {
    @BindingViewState var weatherEntry: WeatherEntry?
    var weatherStatus: ExtraContentPathFeature.State.WeatherStatus
    
    init(bindingViewStore: BindingViewStore<ExtraContentPathFeature.State>) {
      self._weatherEntry = bindingViewStore.$weatherEntry
      self.weatherStatus = bindingViewStore.weatherStatus
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      if case .error(_) = viewStore.weatherStatus {
        VStack{
          DynamicInfoActionHStack(
            message: "We couldn't fetch the weather. Retry or pick manually",
            actionTitle: "Retry",
            actionBackgroundColor: .black,
            action: {
              viewStore.send(.fetchCurrentWeatherButtonTapped, animation: .snappy)
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
        
      } else {
        WeatherEntryView(
          message: message(weatherStatus: viewStore.weatherStatus),
          iconName: iconName(weatherStatus: viewStore.weatherStatus),
          redactedCondition: viewStore.weatherStatus == .loading || viewStore.weatherStatus == .none
        )
      }
    }
  }
  
  private func message(weatherStatus: ExtraContentPathFeature.State.WeatherStatus) -> String {
    switch weatherStatus {
      case .loading, .none:
        return .placeholder(length: 10)
      case let .result(weatherEntry):
        return weatherEntry.rawValue.capitalized
      default:
        return ""
    }
  }
  
  private func iconName(weatherStatus: ExtraContentPathFeature.State.WeatherStatus) -> String {
    switch weatherStatus {
      case let .result(weatherEntry):
        return weatherEntry.selectedIcon
      default:
        return WeatherEntry.cloudy.unselectedIcon
    }
  }
}

#Preview("Location authorized loading") {
  WeatherWhenLocationAuthorizedView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside",
        weatherStatus: .loading
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockAuthorizedWhenInUse
        dependecyValues.weatherClient = .failure(delay: 1.0)
      }
    )
    
  )
  .padding(.horizontal)
}

#Preview("Location authorized sunny") {
  WeatherWhenLocationAuthorizedView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside",
        weatherStatus: .result(.sunny)
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockAuthorizedWhenInUse
        dependecyValues.weatherClient = .mock(.sunny, delay: 1.0)
      }
    )
    
  )
  .padding(.horizontal)
}

#Preview("Location authorized error") {
  WeatherWhenLocationAuthorizedView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside",
        weatherStatus: .error(message: "Something went wrong")
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockAuthorizedWhenInUse
        dependecyValues.weatherClient = .failure(delay: 1.0)
      }
    )
    
  )
  .padding(.horizontal)
}
