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
import PersistentClient
import NoteEntryFeature

@Reducer
public struct MoodEntryFeature: Reducer {
  
  public init() {
    
  }
  
  public struct State: Equatable {
    @BindingState var moodEntry: MoodEntry
    
    var moodPath: MoodPathFeature.State
    var activityPath: ActivityPathFeature.State
    var extraContentPath: ExtraContentPathFeature.State
    
    var backgroundColor: Color
    let currentDate: Date
    
    let availableActivities: [Activity] = Activity.allCases
    
    @PresentationState var notes: NoteEntryFeature.State?
    
    public init(moodEntry: MoodEntry) {
      @Dependency(\.date.now) var now
      self.moodEntry = moodEntry
      self.currentDate = now
            
      self.backgroundColor = Color(moodEntry.colorCode)
      
      self.moodPath = MoodPathFeature.State(moodScale: moodEntry.moodScale, mood: moodEntry.mood)
      self.activityPath = ActivityPathFeature.State(
        availableActivities: Activity.allCases,
        selectedActivities: moodEntry.activities
      )
      
      self.extraContentPath = ExtraContentPathFeature.State(
        notes: moodEntry.observations ?? "",
        weatherEntry: moodEntry.weatherEntry
      )
    }
    
    enum Field: Hashable {
      case observations
    }
    
    public enum Path: String, CaseIterable, RawRepresentable, Equatable, SegmentedItem {
      case mood
      case activity
      case notes
      
      public var id: String {
        self.rawValue
      }
      
      public var isLastStep: Bool {
        self == .notes
      }
      
      public var isFirstStep: Bool {
        self == .mood
      }
      
      public var iconSystemName: String {
        switch self {
          case .mood:
            return "face.smiling"
          case .activity:
            return "figure.walk"
          case .notes:
            return "square.and.pencil"
        }
      }
      
      public var title: String {
        switch self {
          case .mood:
            return "Mood"
          case .activity:
            return "Activities"
          case .notes:
            return "Extras"
        }
      }
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    
    case moodPath(MoodPathFeature.Action)
    case activityPath(ActivityPathFeature.Action)
    case extraContentPath(ExtraContentPathFeature.Action)
    
    case delegate(Delegate)
    
    case createMoodEntryButtonTapped
    case closeMoodEntryButtonTapped
    
    case notes(PresentationAction<NoteEntryFeature.Action>)
    
    public enum Delegate: Equatable {
      case saveMoodEntry(MoodEntry)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.persistentClient) var persistentClient
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Scope(state: \.moodPath, action: \.moodPath) {
      MoodPathFeature()
    }
    
    Scope(state: \.activityPath, action: \.activityPath) {
      ActivityPathFeature()
    }
    
    Scope(state: \.extraContentPath, action: \.extraContentPath) {
      ExtraContentPathFeature()
    }
    
    Reduce { state, action in
      switch action {
        case .binding:
          return .none
          
        case .delegate:
          return .none
          
        case let .notes(.presented(.delegate(delegate))):
          switch delegate {
            case let .updateNotes(notes):
              state.moodEntry.observations = notes
              state.extraContentPath.notes = notes
              state.notes = nil
            case .closeNotes:
              state.notes = nil
          }
          return .none
          
        case .notes:
          return .none
                    
        case .createMoodEntryButtonTapped:
          return .run { [moodEntry = state.moodEntry] send in
            
            do {
              try self.persistentClient.addMoodEntry(moodEntry)
              await send(.delegate(.saveMoodEntry(moodEntry)))
              await self.dismiss()
            } catch {
              // Handle error
              
            }

          }
          
        case .closeMoodEntryButtonTapped:
          return .run { _ in
            await self.dismiss()
          }
          
        case let .moodPath(.delegate(delegate)):
          switch delegate {
            case let .update(resolvedColor, mood, moodScale):
              state.moodEntry.colorCode = resolvedColor
              state.backgroundColor = Color(resolvedColor)
              if let mood {
                state.moodEntry.mood = mood
              }
              state.moodEntry.moodScale = moodScale
          }
          return .none
        case .moodPath:
          return .none
          
        case let .activityPath(.delegate(delegate)):
          switch delegate {
            case let .updateActivities(activities):
              state.moodEntry.activities = activities
          }
          return .none
          
        case .activityPath:
          return .none
          
        case let .extraContentPath(.delegate(delegate)):
          switch delegate {
            case let .updateWeatherEntry(weatherEntry):
              state.moodEntry.weatherEntry = weatherEntry
            case .displayNotes:
              state.notes = NoteEntryFeature.State(notes: state.moodEntry.observations ?? "")
          }
          return .none
        case .extraContentPath:
          return .none
      }
      
    }
    .ifLet(\.$notes, action: \.notes) {
      NoteEntryFeature()
    }
    ._printChanges()
  }
}

public struct MoodEntryRootView: View {
  let store: StoreOf<MoodEntryFeature>
  
  public init(store: StoreOf<MoodEntryFeature>) {
    self.store = store
  }
  
  @State private var changeDate: Bool = false
  @State private var showBackground: Bool = false
  @State private var selectedDate: Date = .now
  @State private var onShowObservations: Bool = false
  
  @Namespace var namespace
  
  struct ViewState: Equatable {
    var showNotes: Bool
    
    init(state: MoodEntryFeature.State) {
      self.showNotes = state.notes != nil
    }
  }
  
  public var body: some View {
    let _ = Self._printChanges()
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      MoodEntryNavigationView(
        self.store,
        onShowObservations: self.$onShowObservations,
        namespace: namespace
      ) { path in
        switch path {
          case .mood:
            MoodPathView(store: self.store.scope(state: \.moodPath, action: \.moodPath))
          case .activity:
            ActivityPathView(store: self.store.scope(state: \.activityPath, action: \.activityPath))
          case .notes:
            ExtraContentPathView(
              store: self.store.scope(state: \.extraContentPath, action: \.extraContentPath),
              onShowObservations: $onShowObservations,
              namespace: namespace
            )
        }
      }
      .onChange(of: viewStore.showNotes) { oldValue, newValue in
        withAnimation(.snappy) {
          self.onShowObservations = newValue
        }
      }
    }
  }
}

struct MoodEntryNavigationView<DestinationContent: View>: View {
  let store: StoreOf<MoodEntryFeature>
  let destination: (MoodEntryFeature.State.Path) -> DestinationContent
  
  @Binding var onShowObservations: Bool
  @State private var visiblePath: MoodEntryFeature.State.Path? = .mood
  
  let namespace: Namespace.ID
  
  init(
    _ store: StoreOf<MoodEntryFeature>,
    onShowObservations: Binding<Bool>,
    namespace: Namespace.ID,
    @ViewBuilder destination: @escaping (_ path: MoodEntryFeature.State.Path) -> DestinationContent
  ) {
    self.store = store
    self.namespace = namespace
    self._onShowObservations = onShowObservations
    self.destination = destination
  }
  
  struct ViewState: Equatable {
    var backgroundColor: Color
    @BindingViewState var date: Date {
      didSet {
        self.displayedDate = formatDate(self.date)
      }
    }
    var currentDate: Date
    var displayedDate: String = ""
    
    init(bindingViewStore: BindingViewStore<MoodEntryFeature.State>) {
      self.backgroundColor = bindingViewStore.backgroundColor
      self._date = bindingViewStore.$moodEntry.date
      self.currentDate = bindingViewStore.currentDate
      self.displayedDate = self.formatDate(bindingViewStore.moodEntry.date)
    }
    
    private func formatDate(_ date: Date) -> String {
      @Dependency(\.formatters.formatDate) var formatDate
      return formatDate(.datePicker)(date)
    }
  }
  
  @State private var updateMoodEntryDate: Bool = false
  @State private var testId: Int?
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      let _ = Self._printChanges()
      
      HTabContainerView(
        tabItems: MoodEntryFeature.State.Path.allCases,
        selectedTab: $visiblePath,
        content: destination,
        shouldHideActionContent: { onShowObservations }
      )
      .zIndex(1)
      .moodEntry(
        backgroundColor: viewStore.backgroundColor,
        currentDate: viewStore.currentDate,
        date: viewStore.$date,
        displayedDate: viewStore.displayedDate,
        primaryAction: {
          Button(
            action: {
              viewStore.send(.createMoodEntryButtonTapped)
            },
            label: {
              Text("Finish")
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
            }
          )
          .primaryButton(backgroundStyle: .black)
        },
        trailingAction: {
          Button(
            action: {
              viewStore.send(.closeMoodEntryButtonTapped)
            },
            label: {
              Image(systemName: "xmark")
                .font(.title3.bold())
                .padding(.horizontal)
            }
          )
          .scaledButton(scaleFactor: 0.9)
        },
        shouldHideActionContent: { onShowObservations }
      )
      .showNotes(store: self.store.scope(state: \.notes, action: \.notes.presented)) { store in
        NotesView(store: store, namespace: self.namespace)
      }
    }
    
  }
}

extension View {
  func showNotes<State, Action, Content: View>(
    store: Store<State?, Action>,
    @ViewBuilder content: @escaping (_ store: Store<State, Action>) -> Content
  ) -> some View {
    ZStack {
      self
      IfLetStore(store) { store in
        content(store)
      }
      .zIndex(1.0)
    }
  }
}

#Preview("Location authorized") {
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
        dependecyValues.weatherClient = .mock(.cloudy, delay: 2.0)
      }
    )
  )
}

#Preview("Location not determined") {
  MoodEntryRootView(
    store: Store(
      initialState: MoodEntryFeature.State(
        moodEntry: .mockMeh()
      ),
      reducer : {
        MoodEntryFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockNotDetermined
        dependecyValues.weatherClient = .mock(.cloudy, delay: 2.0)
      }
    )
  )
}
