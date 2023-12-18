//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-12.
//

import SwiftUI
import ComposableArchitecture
import EntryListFeature
import Models
import UIComponents

@Reducer
public struct RootFeature: Reducer {
    public struct State: Equatable {
        var entryList: EntryListFeature.State
        
        var selectedTab: Tab = .entryList
    }
    
    public enum Action {
        case entryList(EntryListFeature.Action)
        case selectedTabChanged(Tab)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .entryList:
                return .none
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            }
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
                    print("Custom action 1")
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
        }
    }
}

#Preview {
    RootView(
        store: Store<RootFeature.State, RootFeature.Action>(
            initialState: RootFeature.State(entryList: EntryListFeature.State(entries: .mockMood()))
        ) {
            RootFeature()
        }
    )
}
