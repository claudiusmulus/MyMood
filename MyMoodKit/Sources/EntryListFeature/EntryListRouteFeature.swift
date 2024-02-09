//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import SwiftUI
import ComposableArchitecture
import UIComponents

@Reducer
public struct EntryListRouteFeature {
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var navigationPath: StackState<NavigationPath.State>
    
    var filterPath: FilterPath?
    
    var dailyEntriesFilterPath: EntryListDailyFeature.State
    
    public init(
      filterPath: FilterPath = .today,
      navigationPath: StackState<NavigationPath.State> = StackState<NavigationPath.State>()
    ) {
      self.filterPath = filterPath
      self.navigationPath = navigationPath
      self.dailyEntriesFilterPath = EntryListDailyFeature.State()
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case dailyEntriesFilterPath(EntryListDailyFeature.Action)
    case binding(BindingAction<State>)
    case navigationPath(StackAction<NavigationPath.State, NavigationPath.Action>)
  }
  
  @Reducer
  public struct NavigationPath: Reducer {
    @ObservableState
    public enum State: Equatable {
      case moodDetails
    }
    public enum Action: Equatable {
      case moodDetails
    }
    public var body: some ReducerOf<Self> {
      Scope(state: /State.moodDetails, action: /Action.moodDetails) {
        EmptyReducer()
      }
    }
  }
  
  public enum FilterPath: String, CaseIterable, Equatable, SegmentedItem {
    
    case today
    case week
    case month
    
    public var id: String {
      self.rawValue
    }
    
    public var title: String {
      switch self {
        case .today:
          return "Today"
        case .week:
          return "This week"
        case .month:
          return "Month"
      }
    }
    
    public var iconSystemName: String {
      return "person"
    }
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Scope(state: \.dailyEntriesFilterPath, action: \.dailyEntriesFilterPath) {
      EntryListDailyFeature()
    }
    
    Reduce { state, action in
      switch action {
        case .binding:
          return .none
          
        case .dailyEntriesFilterPath:
          return .none
          
        case .navigationPath:
          return .none
      }
    }
    .forEach(\.navigationPath, action: \.navigationPath) {
      NavigationPath()
    }
  }
  
}

public struct EntryListRouteView: View {
  
  @Bindable var store: StoreOf<EntryListRouteFeature>
  
  public init(store: StoreOf<EntryListRouteFeature>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack(
      path: self.$store.scope(
        state: \.navigationPath,
        action: \.navigationPath
      ),
      root: {
        HTabContainerView(
          tabItems: EntryListRouteFeature.FilterPath.allCases,
          selectedTab: self.$store.filterPath,
          content: { tabItem in
            switch tabItem {
              case .today:
                EntryListDailyView(
                  store: self.store.scope(
                    state: \.dailyEntriesFilterPath,
                    action: \.dailyEntriesFilterPath
                  )
                )
              case .week:
                Text("Week")
              case .month:
                Text("Month")
            }
          },
          shouldHideActionContent: { false }
        )
        .padding(.top, 10)
      },
      destination: { store in
        switch store.state {
          case .moodDetails:
            Text("MoodDetails")
        }
      }
    )

  }
}

#Preview {
  EntryListRouteView(
    store: .init(
      initialState: EntryListRouteFeature.State(),
      reducer: {
        EntryListRouteFeature()
      }, 
      withDependencies: { dependencyValues in
        
      }
    )
  )
}
