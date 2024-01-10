//
//  ContentView.swift
//  MyMood
//
//  Created by Alberto Novo Garrido on 2023-12-07.
//

import SwiftUI
import Theme
import MoodEntryFeature
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
//        MoodEntryRootView(
//            store: Store(
//                initialState: MoodEntryFeature.State(
//                    moodEntry: .mockMeh()
//                )
//            ) {
//                MoodEntryFeature()
//            }
//        )
        MoodEntryRootView(
            store: Store(
                initialState: MoodEntryFeature.State(
                    moodEntry: .mockMeh()
                ),
                reducer : {
                    MoodEntryFeature()
                },
                withDependencies: { dependecyValues in
                    dependecyValues.locationClient = .mockDenied
                    dependecyValues.weatherClient = .mock(.cloudy, delay: 1.0)
                }
            )
        )
    }
}

#Preview {
    ContentView()
}
