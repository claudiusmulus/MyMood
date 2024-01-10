//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-19.
//

import SwiftUI
import ComposableArchitecture
import Models
import ColorGeneratorClient
import FormattersClient
import UIComponents
import LocationClient
import WeatherClient

@Reducer
public struct MoodEntryFeature: Reducer {
    
    public init() {
        
    }
    
    public struct State: Equatable {
        @BindingState var moodEntry: MoodEntry
        @BindingState var path: Path?
        @BindingState var focus: Field?
        
        var backgroundColor: Color
        let currentDate: Date
        let availableActivities: [Activity] = Activity.allCases
        var weatherDisplay: WeatherDisplay
        var weatherStatus: WeatherStatus
        
        public init(
            moodEntry: MoodEntry,
            weatherDisplay: WeatherDisplay = .whenLocationNotDetermined,
            weatherStatus: WeatherStatus = .none
        ) {
            @Dependency(\.date.now) var now
            self.moodEntry = moodEntry
            self.currentDate = now
            self.backgroundColor = Color(moodEntry.colorCode)
            self.weatherDisplay = weatherDisplay
            self.weatherStatus = weatherStatus
            self.path = .mood
        }
        
        enum Field: Hashable {
          case observations
        }
        
        public enum WeatherDisplay: Equatable {
            case whenLocationNotDetermined
            case whenLocationDenied
            case whenLocationAuthorized
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
        case nextButtonTapped
        case selectActivity(Activity)
        case deselectActivity(Activity.Id)
        case delegate(Delegate)
        case popPathTapped
        case onAppear
        case fetchCurrentWeather
        case weatherDisplay(State.WeatherDisplay)
        case weatherStatus(State.WeatherStatus)
        case goToSettingsButtonTapped
        case createMoodEntryButtonTapped
        case closeMoodEntryButtonTapped
        
        public enum Delegate: Equatable {
            case saveMoodEntry(MoodEntry)
        }
    }
    
    enum Path: String, CaseIterable, RawRepresentable, Hashable {
        case mood
        case activity
        case notes
        
        var id: String {
            switch self {
            case .mood:
                return "mood"
            case .activity:
                return "activity"
            case .notes:
                return "notes"
            }
        }
        
        var isLastStep: Bool {
            self == .notes
        }
        
        var isFirstStep: Bool {
            self == .mood
        }
    }
    
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.weatherClient) var weatherClient
    @Dependency(\.openURL) var openURL
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.moodEntry.moodScale) { oldValue, newValue in
                Reduce { state, _ in
                    @Dependency(\.colorGenerator) var colorGenerator
                    let resolvedColor = colorGenerator.generatedColor(amount: Float(newValue))
                    state.moodEntry.colorCode = resolvedColor
                    state.backgroundColor = Color(resolvedColor)
                    if let newMood = mood(scale: newValue) {
                        state.moodEntry.mood = newMood
                    }
                    return .none
                }
            }
            //._printChanges()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .nextButtonTapped:
                guard let currentPath = state.path else {
                    return .none
                }
                switch currentPath {
                case .mood:
                    state.path = .activity
                case .activity:
                    state.path = .notes
                case .notes:
                    break
                }
                return .none
            case let .selectActivity(activity):
                
                if !state.moodEntry.activities.contains(activity) {
                    state.moodEntry.activities.append(activity)
                }
                
                return .none
            case .delegate:
                return .none
            case let .deselectActivity(id):
                state.moodEntry.activities.remove(id: id)
                return .none
            case .popPathTapped:
                guard let currentPath = state.path else {
                    return .none
                }
                switch currentPath {
                case .mood:
                    break
                case .activity:
                    state.path = .mood
                case .notes:
                    state.path = .activity
                }
                
                return .none
                
            case .fetchCurrentWeather:
                return .run { send in
                    await send(.weatherStatus(.loading), animation: .snappy)
                    do {
                        guard let currentLocation = try await locationClient.requestUserLocation() else {
                            await send(.weatherStatus(.error(message: "Location not available")), animation: .snappy)
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
                                await send(.weatherDisplay(.whenLocationDenied))
                            default:
                                await send(.weatherStatus(.error(message: "Location not available")), animation: .snappy)
                            }
                        } else {
                            await send(.weatherStatus(.error(message: "Weather not available")), animation: .snappy)
                        }
                    }
                }
                
            case .onAppear:
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
                    state.moodEntry.weatherEntry = weatherEntry
                }
                
                return .none
            case let .weatherDisplay(weatherDisplay):
                state.weatherDisplay = weatherDisplay
                
                if weatherDisplay == .whenLocationAuthorized {
                    return .run { send in
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
                } else {
                    return .none
                }
            case .goToSettingsButtonTapped:
                return .run { _ in
                    if let url = await URL(string: UIApplication.openSettingsURLString) {
                        await self.openURL(url)
                    }
                }
            case .createMoodEntryButtonTapped:
                return .run { [state = state] send in
                    await send(.delegate(.saveMoodEntry(state.moodEntry)))
                }
                
            case .closeMoodEntryButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
        ._printChanges()
    }
    
    private func mood(scale: Double) -> Mood? {
        guard scale >= 0, scale <= 1 else {
            return nil
        }
        switch scale {
        case 0..<0.20:
            return .terrible
        case 0.20..<0.40:
            return .bad
        case 0.40..<0.60:
            return .okay
        case 0.60..<0.80:
            return .good
        case 0.80...1:
            return .awesome
        default:
            return nil
        }
    }
}

public struct MoodEntryRootView: View {
    let store: StoreOf<MoodEntryFeature>
    
    public init(store: StoreOf<MoodEntryFeature>) {
        self.store = store
    }
    
    @State private var onAppear: Bool = false
    @State private var changeDate: Bool = false
    @State private var showBackground: Bool = false
    @State private var selectedDate: Date = .now
    @State private var isActionButtonsVisible: Bool = true
    
    
    public var body: some View {
        MoodEntryNavigationView(
            self.store,
            isActionButtonsVisible: self.$isActionButtonsVisible
        ) { path in
            switch path {
            case .mood:
                MoodPathView(store: self.store)
            case .activity:
                ActivityPathView(store: self.store)
            case .notes:
                ExtraContentPathView(store: self.store) { isObservationsVisible in
                    withAnimation(.snappy) {
                        self.isActionButtonsVisible = !isObservationsVisible
                    }
                }
            }
        }
    }
}

struct MoodEntryNavigationView<DestinationContent: View>: View {
    let store: StoreOf<MoodEntryFeature>
    let destination: (MoodEntryFeature.Path) -> DestinationContent
    
    @Binding var isActionButtonsVisible: Bool
    
    init(
        _ store: StoreOf<MoodEntryFeature>,
        isActionButtonsVisible: Binding<Bool>,
        @ViewBuilder destination: @escaping (_ path: MoodEntryFeature.Path) -> DestinationContent
    ) {
        self.store = store
        self._isActionButtonsVisible = isActionButtonsVisible
        self.destination = destination
    }
    
    struct ViewState: Equatable {
        var backgroundColor: Color
        @BindingViewState var date: Date {
            didSet {
                self.displayedDate = formatDate(self.date)
            }
        }
        @BindingViewState var path: MoodEntryFeature.Path?
        var focus: MoodEntryFeature.State.Field?
        var currentDate: Date
        var displayedDate: String = ""
        
        init(bindingViewStore: BindingViewStore<MoodEntryFeature.State>) {
            self.backgroundColor = bindingViewStore.backgroundColor
            self._date = bindingViewStore.$moodEntry.date
            self._path = bindingViewStore.$path
            self.focus = bindingViewStore.focus
            self.currentDate = bindingViewStore.currentDate
            self.displayedDate = self.formatDate(bindingViewStore.moodEntry.date)
        }
        
        private func formatDate(_ date: Date) -> String {
            @Dependency(\.formatters.formatDate) var formatDate
            return formatDate(date, .datePicker)
        }
    }
    
    
    @State private var updateMoodEntryDate: Bool = false
    @State private var testId: Int?
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            GeometryReader {
                let size = $0.size
                
                ZStack(alignment: .top) {
                    viewStore.backgroundColor.ignoresSafeArea()
                    
                    // Navigation bar
                    ZStack {
                        
                        if !self.updateMoodEntryDate {
                            Button(
                                action: {
                                    withAnimation(.snappy) {
                                        self.updateMoodEntryDate = true
                                    }
                            },
                                label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar")
                                            .font(.title3.bold())
                                        Text(viewStore.displayedDate)
                                            .fontWeight(.bold)
                                    }
                            })
                            .scaledButton()
                            .frame(height: 44)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            
                        }
                        HStack(spacing: 0) {
                            if let currentPath = viewStore.path, !currentPath.isFirstStep, !self.updateMoodEntryDate {
                                Button(
                                    action: {
                                        viewStore.send(.popPathTapped, animation: .snappy)
                                },
                                    label: {
                                        Image(systemName: "arrow.backward")
                                            .font(.title3.bold())
                                            .padding(.horizontal)
                                })
                                .scaledButton(scaleFactor: 0.9)
                                .frame(height: 44)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                            }
                            
                            Spacer()

                            HStack(spacing: 0) {
                                if self.updateMoodEntryDate {
                                    Button(
                                        action: {
                                            withAnimation(.snappy) {
                                                self.updateMoodEntryDate = false
                                            }
                                    },
                                        label: {
                                            Image(systemName: "checkmark")
                                                .font(.title3.bold())
                                                .padding(.horizontal)
                                    })
                                    .frame(width: 44, height: 44)
                                    .transition(.opacity.combined(with: .offset(x: 20)))
                                } else {
                                    Button(
                                        action: {
                                            viewStore.send(.closeMoodEntryButtonTapped)
                                    },
                                        label: {
                                            Image(systemName: "xmark")
                                                .font(.title3.bold())
                                                .padding(.horizontal)
                                    })
                                    .frame(width: 44, height: 44)
                                    .transition(.opacity.combined(with: .offset(x: -20)))
                                }
                            }
                            .scaledButton(scaleFactor: 0.9)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .tint(.black)
                    .background(viewStore.backgroundColor)
                    .zIndex(100)
                    .opacity(isActionButtonsVisible ? 1 : 0)
                    .offset(y: isActionButtonsVisible ? 0 : -200)

                    // Calendar view
                    if self.updateMoodEntryDate {
                        
                        Group {
                            viewStore
                                .backgroundColor
                                .frame(height: 380)
                                .frame(maxWidth: .infinity)
                                .transition(.move(edge: .top))
                                .zIndex(15)
                            
                            DatePicker(
                                "Entry Date",
                                selection: viewStore.$date,
                                in: ...viewStore.currentDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .frame(width: size.width * 0.8, height: 360)
                            .zIndex(20)
                            .frame(maxWidth: .infinity)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.animation(.linear.delay(0.25)),
                                    removal: .offset(y: -50).combined(with: .opacity)
                                )
                            )
                            .tint(.black)
                            
                            VStack {
                                viewStore.backgroundColor.frame(height: 100)
                                    .transition(.move(edge: .top))
                                Color.black.opacity(0.6)
                                    .ignoresSafeArea(edges: .bottom)
                                    .transition(.opacity)
                                    .onTapGesture {}
                            }
                            .zIndex(5)
                        }
                        .padding(.top, 44)
                        .zIndex(20)
                    }
                    
                    VStack {
                        ScrollView(.horizontal) {
                            HStack(spacing: 0) {
                                ForEach(MoodEntryFeature.Path.allCases, id: \.id) { path in
                                    destination(path)
                                        .id(path)
                                        .containerRelativeFrame(.horizontal)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: viewStore.$path)
                        .scrollDisabled(true)
                    }
                    .padding(.top, 44)
                    .zIndex(1)
                    
                    // Buttons view
                    HStack {
                        Button(
                            action: {
                                viewStore.send(.createMoodEntryButtonTapped)
                            },
                            label: {
                                Text("Finish")
                                    .frame(maxWidth: .infinity)
                            }
                        )
                        .actionButton(borderColor: viewStore.backgroundColor.adaptedTextColor)
                        .padding(.leading, 20)
                        .padding(.trailing, 10)
                        
                        if let currentPath = viewStore.path, !currentPath.isLastStep {
                            Button(
                                action: {
                                    viewStore.send(.nextButtonTapped, animation: .linear)
                                },
                                label: {
                                    Text("Next")
                                        .frame(maxWidth: .infinity)
                                }
                            )
                            .actionButton(borderColor: viewStore.backgroundColor.adaptedTextColor)
                            .padding(.leading, 10)
                            .padding(.trailing, 20)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                        }
                    }
                    .zIndex(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.vertical)
                    .opacity(isActionButtonsVisible ? 1 : 0)
                    .offset(y: isActionButtonsVisible ? 0 : 100)
                    .onChange(of: viewStore.focus, { _, newValue in
                        withAnimation(.snappy) {
                            self.isActionButtonsVisible = (newValue == nil)
                        }
                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        
    }
}

extension Color {
    func luminance() -> Double {
        let rgbColor = self.rgba
        
        return 0.2126 * Double(rgbColor.red) + 0.7152 * Double(rgbColor.green) + 0.0722 * Double(rgbColor.blue)
    }
    
    func isLight() -> Bool {
        return self.luminance() > 0.5
    }
    
    var adaptedTextColor: Color {
        return self.isLight() ? .black : .white
    }
}

#Preview {
    MoodEntryRootView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .mock(.cloudy, delay: 1.0)
            }
        )
    )
}
