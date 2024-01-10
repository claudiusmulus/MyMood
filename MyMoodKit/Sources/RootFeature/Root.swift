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
    public struct State: Equatable {
        var entryList: EntryListFeature.State
        var selectedTab: Tab = .entryList
        @PresentationState var destination: Destination.State?
    }
    
    public enum Action {
        case entryList(EntryListFeature.Action)
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
            case .addMoodEntryButtonTapped:
                state.destination = .addMoodEntry(MoodEntryFeature.State(moodEntry: .new))
                return .none
            case let .destination(.presented(.addMoodEntry(.delegate(delegate)))):
                switch delegate {
                case let .saveMoodEntry(moodEntry):
                    state.entryList.entries.append(.mood(moodEntry))
                }
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
            EntryListFeature()
        }
    }
}

struct RootView: View {
    let store: StoreOf<RootFeature>
    
    struct ViewState {
        var selectedTab: Tab
        
        init(state: RootFeature.State) {
            self.selectedTab = state.selectedTab
        }
    }
    var body: some View {
        
        WithViewStore(self.store, observe: \.selectedTab) { viewStore in
            CustomTabView(
                selection: viewStore.binding(send: RootFeature.Action.selectedTabChanged),
                firstAction: .firstOptionMock,
                secondAction: .secondOptionMock,
                onPrimaryAction: {
                    viewStore.send(.addMoodEntryButtonTapped)
                },
                onSecondaryAction: {
                    print("Custom action 2")
                }
            ) {
                switch $0 {
                case .entryList:
                    EntryListView(store: self.store.scope(state: \.entryList, action: \.entryList))
                        .tag(Tab.entryList)
                        .toolbar(.hidden, for: .tabBar)
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
            }
        }
    }
}

#Preview {
    RootView(
        store: Store<RootFeature.State, RootFeature.Action>(
            initialState: RootFeature.State(entryList: EntryListFeature.State(entries: []))
        ) {
            RootFeature()
        }
    )
}
