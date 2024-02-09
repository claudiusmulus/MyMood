  //
  //  SwiftUIView.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2023-12-12.
  //

import SwiftUI
import ComposableArchitecture
import EntryListFeature
import MoodEntryFeature
import Models
import UIComponents

@Reducer
public struct RootFeature: Reducer {
  
  public init(){
    
  }
  
  public struct State: Equatable {
    var entryList: EntryListRouteFeature.State
    var selectedTab: Tab
    @PresentationState var destination: Destination.State?
    
    public init(
      entryList: EntryListRouteFeature.State,
      selectedTab: Tab = .entryList,
      destination: Destination.State? = nil
    ) {
      self.entryList = entryList
      self.selectedTab = selectedTab
      self.destination = destination
    }
  }
  
  public enum Action {
    case addMenuButtonTapped
    case entryList(EntryListRouteFeature.Action)
    case selectedTabChanged(Tab)
    case destination(PresentationAction<Destination.Action>)
    case addMoodEntryButtonTapped
  }
  
  @Reducer
  public struct Destination: Reducer {
    public enum State: Equatable {
      case addMoodEntry(MoodEntryFeature.State)
      case addNote
    }
    public enum Action: Equatable {
      case addMoodEntry(MoodEntryFeature.Action)
      case addNote
    }
    public var body: some ReducerOf<Self> {
      Scope(state: /State.addMoodEntry, action: /Action.addMoodEntry) {
        MoodEntryFeature()
      }
    }
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .addMenuButtonTapped:
          return .none
        case .addMoodEntryButtonTapped:
          state.destination = .addMoodEntry(MoodEntryFeature.State(moodEntry: MoodEntry()))
          return .none
        case .destination:
          return .none
        case .entryList:
          return .none
        case let .selectedTabChanged(tab):
          state.selectedTab = tab
          return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
    Scope(state: \.entryList, action: \.entryList) {
      EntryListRouteFeature()
    }
    ._printChanges()
  }
}

public struct RootView: View {
  let store: StoreOf<RootFeature>
  
  public init(store: StoreOf<RootFeature>) {
    self.store = store
  }
  
  public var body: some View {
    
    WithViewStore(self.store, observe: \.selectedTab) { viewStore in
      CustomTabView(
        selection: viewStore.binding(send: RootFeature.Action.selectedTabChanged),
        firstAction: .moodCheckin,
        secondAction: .secondOptionMock,
        onMenuAction: {
          viewStore.send(.addMenuButtonTapped, animation: .snappy)
        },
        onPrimaryAction: {
          viewStore.send(.addMoodEntryButtonTapped)
        },
        onSecondaryAction: {
          print("Custom action 2")
        }
      ) {
        switch $0 {
          case .entryList:
          
            EntryListRouteView(
              store: self.store.scope(
                state: \.entryList,
                action: \.entryList
              )
            )
            .tag(Tab.entryList)
            
          case .stats:
            Text("Stats")
              .tag(Tab.stats)
              .toolbar(.hidden, for: .tabBar)
        }
      }
      .sheet(
        store: self.store.scope(
          state: \.$destination.addMoodEntry,
          action: \.destination.addMoodEntry)
      ) { store in
        MoodEntryRootView(store: store)
          .interactiveDismissDisabled(true)
      }
    }
  }
}

#Preview {
  RootView(
    store: Store<RootFeature.State, RootFeature.Action>(
      initialState: RootFeature.State(
        entryList: EntryListRouteFeature.State()
      ),
      reducer: {
        RootFeature()
      },
      withDependencies: { dependecyValues in
        dependecyValues.locationClient = .mockNotDetermined
        dependecyValues.weatherClient = .mock(.sunny, delay: 1.0)
      }
    )
  )
}
