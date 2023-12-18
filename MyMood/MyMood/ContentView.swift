//
//  ContentView.swift
//  MyMood
//
//  Created by Alberto Novo Garrido on 2023-12-07.
//

import SwiftUI
import Theme

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Text(
                "red: \(Color.moodRed.rgba.red), \ngreen: \(Color.moodRed.rgba.green), \nblue: \(Color.moodRed.rgba.blue)"
            )
            .foregroundStyle(.moodRed)
            Text(
                "red: \(Color.moodYellow.rgba.red), \ngreen: \(Color.moodYellow.rgba.green), \nblue: \(Color.moodYellow.rgba.blue)"
            )
            .foregroundStyle(.moodYellow)
            Text(
                "red: \(Color.moodGreen.rgba.red), \ngreen: \(Color.moodGreen.rgba.green), \nblue: \(Color.moodGreen.rgba.blue)"
            )
            .foregroundStyle(.moodGreen)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
