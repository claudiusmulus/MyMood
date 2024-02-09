//
//  ContentView.swift
//  MyMood
//
//  Created by Alberto Novo Garrido on 2023-12-07.
//

import SwiftUI
import Theme
import RootFeature
import EntryListFeature
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        RootView(
            store: Store<RootFeature.State, RootFeature.Action>(
                initialState: RootFeature.State(entryList: EntryListRouteFeature.State())
            ) {
                RootFeature()
            }
        )
//      RootView(
//        store: Store<RootFeature.State, RootFeature.Action>(
//          initialState: RootFeature.State(
//            entryList: EntryListRouteFeature.State()
//          ),
//          reducer: {
//            RootFeature()
//          },
//          withDependencies: { dependecyValues in
//            dependecyValues.locationClient = .mockNotDetermined
//            dependecyValues.weatherClient = .mock(.sunny, delay: 1.0)
////            dependecyValues.persistentClient.fetchEntries = { _ in
////              [.mood(.mockAwesome())]
////            }
//          }
//        )
//      )
    }
}

#Preview {
    ContentView()
}
