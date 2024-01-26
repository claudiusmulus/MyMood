  //
  //  SwiftUIView.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-05.
  //

import SwiftUI
import ComposableArchitecture
import UIComponents
import Models
import LocationClient
import WeatherClient
import CoreLocation

@Reducer
public struct ExtraContentPathFeature: Reducer {
  public struct State: Equatable {
    var notes: String
    @BindingState var weatherEntry: WeatherEntry?
    var locationAuthorizationStatus: CLAuthorizationStatus?
    var weatherDisplay: WeatherDisplay
    var weatherStatus: WeatherStatus
    
    public init(
      notes: String,
      weatherDisplay: WeatherDisplay = .none,
      weatherEntry: WeatherEntry? = nil,
      weatherStatus: WeatherStatus = .none
    ) {
      self.notes = notes
      self.weatherEntry = weatherEntry
      self.weatherStatus = weatherStatus
      self.weatherDisplay = weatherDisplay
    }
    
    public enum WeatherDisplay: Equatable {
      case whenLocationNotDetermined
      case whenLocationDenied
      case whenLocationAuthorized
      case none
    }
    
    public enum WeatherStatus: Equatable {
      case loading
      case result(WeatherEntry)
      case error(message: String)
      case none
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case onAppear
    case fetchCurrentWeather
    case goToSettingsButtonTapped
    case weatherDisplay(State.WeatherDisplay)
    case weatherStatus(State.WeatherStatus)
    
    case showNotesButtonTapped
    
    public enum Delegate: Equatable {
      case updateWeatherEntry(WeatherEntry)
      case displayNotes
    }
  }
  
  @Dependency(\.locationClient) var locationClient
  @Dependency(\.weatherClient) var weatherClient
  @Dependency(\.openURL) var openURL
  
  private enum CancelID {
    case fetchWeatherOnDemand
    case fetchWeatherOnAppear
  }
  
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
      .onChange(of: \.weatherEntry) { oldValue, newValue in
        Reduce { state, _ in
          guard let weatherEntry = newValue else {
            return .none
          }
          return .run { send in
            await send(.delegate(.updateWeatherEntry(weatherEntry)))
          }
        }
      }
    
    Reduce { state, action in
      switch action {
        case .binding:
          return .none
        case .delegate:
          return .none
        case .fetchCurrentWeather:
          guard state.weatherStatus == .loading else {
            return .none
          }
          
          return .merge(
            .cancel(id: CancelID.fetchWeatherOnDemand),
            self.fetchWeatherEffect()
              .cancellable(id: CancelID.fetchWeatherOnDemand, cancelInFlight: true)
          )
          
        case .goToSettingsButtonTapped:
          return .run { _ in
            if let url = await URL(string: UIApplication.openSettingsURLString) {
              await self.openURL(url)
            }
          }
          
        case .onAppear:
          guard state.weatherDisplay == .none else {
            return .none
          }
          return .run { send in
              // Check location permissions. If denied or not determined don't fetch the current weather automatically.
            let currentAuthorizationStatus = await locationClient.authorizationStatus()
            
            switch currentAuthorizationStatus {
              case .authorized, .authorizedAlways, .authorizedWhenInUse:
                await send(.weatherDisplay(.whenLocationAuthorized))
              case .notDetermined:
                await send(.weatherDisplay(.whenLocationNotDetermined))
              case .denied, .restricted:
                await send(.weatherDisplay(.whenLocationDenied))
              default:
                break
            }
            
          }
        case let .weatherStatus(status):
          state.weatherStatus = status
          
          if case let .result(weatherEntry) = status {
            return .run { send in
              await send(.delegate(.updateWeatherEntry(weatherEntry)))
            }
          }
          
          return .none
        case let .weatherDisplay(weatherDisplay):
          state.weatherDisplay = weatherDisplay
          
          if weatherDisplay == .whenLocationAuthorized {
            return .merge(
              .cancel(id: CancelID.fetchWeatherOnAppear),
              self.fetchWeatherEffect()
                .cancellable(id: CancelID.fetchWeatherOnAppear, cancelInFlight: true)
            )
            
          } else {
            return .none
          }
          
        case .showNotesButtonTapped:
          
          return .run { send in
            await send(.delegate(.displayNotes), animation: .snappy)
          }
      }
    }
    ._printChanges()
  }
  
  func fetchWeatherEffect() -> EffectOf<Self> {
    .run { send in
      await send(.weatherStatus(.loading), animation: .snappy)
      do {
        guard let currentLocation = try await locationClient.requestUserLocation() else {
          await send(.weatherStatus(.error(message: "Location not available")))
          return
        }
        let currentWeather = try await weatherClient.weather(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude
        )
        await send(.weatherStatus(.result(currentWeather)), animation: .snappy)
      } catch let error {
        if let locationError = error as? LocationClientError {
          switch locationError {
            case .locationServicesDenied:
              await send(.weatherDisplay(.whenLocationDenied), animation: .snappy)
            default:
              await send(.weatherStatus(.error(message: "Location not available")), animation: .snappy)
          }
        } else {
          await send(.weatherStatus(.error(message: "Weather not available")), animation: .snappy)
        }
      }
    }
  }
}

struct ExtraContentPathView: View {
  
  let store: StoreOf<ExtraContentPathFeature>
  @Binding var onShowObservations: Bool
  
  var namespace: Namespace.ID
  
  struct ViewState: Equatable {
    let notes: String
    let weatherDisplay: ExtraContentPathFeature.State.WeatherDisplay
    
    
    init(state: ExtraContentPathFeature.State) {
      self.notes = state.notes.trimmingCharacters(in: .whitespacesAndNewlines)
      self.weatherDisplay = state.weatherDisplay
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      let _ = Self._printChanges()
        //            ZStack(alignment: .top) {
        //                if !onShowObservations {
        //                    VStack {
        //                        Section {
        //                            WeatherPathView(store: self.store)
        //                        }
        //                        .padding(.top, 40)
        //                        .padding(.horizontal)
        //
        //                        Section {
        //                            VStack {
        //                                HStack {
        //                                    Text("Notes and thoughts")
        //                                        .matchedGeometryEffect(id: "title", in: namespace)
        //                                }
        //                                .frame(maxWidth: .infinity, alignment: .leading)
        //                                .padding(.horizontal)
        //
        //                                Text(viewStore.observations.isEmpty ? "Tap to add extra notes and thoughts" : viewStore.observations.trimmingCharacters(in: .whitespacesAndNewlines))
        //                                    .frame(maxWidth: .infinity, alignment: .leading)
        //                                    .lineLimit(4)
        //                                    .foregroundStyle(viewStore.observations.isEmpty ? .black.opacity(0.3) : .black)
        //                                    .padding()
        //                                    .contentShape(RoundedRectangle(cornerRadius: 10))
        //                                    .overlay {
        //                                        RoundedRectangle(cornerRadius: 10)
        //                                            .stroke(.black, lineWidth: 2.0)
        //                                            .matchedGeometryEffect(id: "border", in: namespace)
        //                                    }
        //                                    .padding(.horizontal)
        //                                    .onTapGesture {
        //                                        withAnimation(.snappy) {
        //                                            self.onShowObservations = true
        //                                        }
        //                                    }
        //                            }
        //                        }
        //                        .padding(.top, 40)
        //                    }
        //                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        //                    .transition(.opacity)
        //
        //                } else {
        //                    ObservationsView(
        //                        text: viewStore.$observations,
        //                        namespace: namespace
        //                    ) {
        //                        withAnimation(.snappy) {
        //                            self.onShowObservations = false
        //                        }
        //                    }
        //                }
        //            }
        //            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      VStack {
        Section {
          WeatherPathView(store: self.store)
        }
        .padding(.top, 40)
        .padding(.horizontal)
        
        Section {
          VStack {
            HStack {
              Text("Notes and thoughts")
                .matchedGeometryEffect(id: "title", in: namespace)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Text(viewStore.notes.isEmpty ? "Tap to add extra notes and thoughts" : viewStore.notes)
              .frame(maxWidth: .infinity, alignment: .leading)
              .lineLimit(4)
              .foregroundStyle(viewStore.notes.isEmpty ? .black.opacity(0.3) : .black)
              .padding()
              .contentShape(RoundedRectangle(cornerRadius: 10))
              .overlay {
                RoundedRectangle(cornerRadius: 10)
                  .stroke(.black, lineWidth: 2.0)
                  .matchedGeometryEffect(id: "border", in: namespace)
              }
              .padding(.horizontal)
              .onTapGesture {
                viewStore.send(.showNotesButtonTapped, animation: .snappy)
              }
          }
        }
        .padding(.top, 40)
      }
      .opacity(onShowObservations ? 0 : 1)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .task {
        guard viewStore.weatherDisplay == .none else {
          return
        }
        viewStore.send(.onAppear)
      }
    }
  }
}

//struct ObservationsView: View {
//  
//  @Binding var text: String
//  
//  @FocusState var isTextFieldFocus: Bool
//  
//  @State private var isAppearing = false
//  
//  var namespace: Namespace.ID
//  
//  var onClose: () -> Void
//  
//  var body: some View {
//    ScrollView {
//      VStack {
//        ZStack(alignment: .bottom) {
//          HStack {
//            Text("Notes and thoughts")
//              .matchedGeometryEffect(id: "title", in: namespace)
//            
//            Spacer()
//          }
//          .frame(maxWidth: .infinity, alignment: .leading)
//          .padding([.horizontal])
//          
//          HStack {
//            Button(
//              action: {
//                self.isTextFieldFocus = false
//                self.onClose()
//              },
//              label: {
//                Image(systemName: "checkmark")
//                  .font(.title2)
//                  .foregroundStyle(.black)
//                  .padding()
//                  .background(
//                    RoundedRectangle(cornerRadius: 10)
//                      .stroke(.black, lineWidth: 2.0)
//                  )
//                  .padding(.horizontal)
//                  .opacity(isAppearing ? 1 : 0)
//                  .offset(x: isAppearing ? 0 : 50)
//                
//              }
//            )
//            .scaledButton()
//            .padding(.top, 1)
//          }
//          .frame(maxWidth: .infinity, alignment: .trailing)
//        }
//        
//        VStack() {
//          TextEditor(text: $text)
//            .scrollContentBackground(.hidden)
//            .padding(20)
//            .foregroundStyle(.black)
//            .tint(.black)
//            .frame(height: 400, alignment: .top)
//            .frame(maxWidth: .infinity)
//            .focused(self.$isTextFieldFocus)
//            .overlay {
//              RoundedRectangle(cornerRadius: 10)
//                .stroke(.black, lineWidth: 2.0)
//                .matchedGeometryEffect(id: "border", in: namespace)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.bottom, 100)
//      }
//    }
//    .scrollBounceBehavior(.basedOnSize)
//    .onAppear {
//      withAnimation(.snappy) {
//        self.isTextFieldFocus = true
//        isAppearing = true
//      }
//    }
//    .onDisappear {
//      withAnimation(.snappy) {
//        self.isTextFieldFocus = false
//      }
//    }
//  }
//}

#Preview("Weather when location not determined") {
  @Namespace var namespace
  return ExtraContentPathView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside"
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockNotDetermined
        dependecyValues.weatherClient = .failure(delay: 1.0)
      }
    ),
    onShowObservations: .constant(false),
    namespace: namespace
  )
}

#Preview("Sunny Weather when location authorized") {
  @Namespace var namespace
  return ExtraContentPathView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside"
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockAuthorizedWhenInUse
        dependecyValues.weatherClient = .mock(.sunny, delay: 2.0)
      }
    ),
    onShowObservations: .constant(false),
    namespace: namespace
  )
}

#Preview("Error when location authorized") {
  @Namespace var namespace
  return ExtraContentPathView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside"
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockAuthorizedWhenInUse
        dependecyValues.weatherClient = .failure(delay: 2.0)
      }
    ),
    onShowObservations: .constant(false),
    namespace: namespace
  )
}

#Preview("When location denied") {
  @Namespace var namespace
  return ExtraContentPathView(
    store: Store(
      initialState: ExtraContentPathFeature.State(
        notes: "Regular day, gray and cloudy. Too cold to go outside"
      ),
      reducer : {
        ExtraContentPathFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockDenied
        dependecyValues.weatherClient = .failure(delay: 2.0)
      }
    ),
    onShowObservations: .constant(false),
    namespace: namespace
  )
}
