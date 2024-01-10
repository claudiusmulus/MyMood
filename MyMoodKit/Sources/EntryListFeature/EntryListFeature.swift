//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-11.
//

import SwiftUI
import ComposableArchitecture
import Models
import Theme
import UIComponents

@Reducer
public struct EntryListFeature {
    
    public init() {}
    
    public struct State: Equatable {
        public var entries: IdentifiedArrayOf<Entry>
        
        public init(entries: IdentifiedArrayOf<Entry>) {
            self.entries = entries
        }
        
    }
    
    public enum Action: Equatable {
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}

public struct EntryListView: View {
    
    let store: StoreOf<EntryListFeature>
    public init(store: StoreOf<EntryListFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            EntryStackView(entries: viewStore.entries) { moodEntry in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(moodEntry.mood.title)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(Color(moodEntry.colorCode))
                            .lineLimit(1)

                        .font(.title.bold())
                        Spacer()
                        Text(moodEntry.date.formatted(date: .omitted, time: .shortened))
                            .font(.body)
                            .foregroundStyle(.secondary)
                        
                    }
                    if !moodEntry.activities.isEmpty {
                        ActivityView(activities: Array(moodEntry.activities.prefix(3)))
                    }
                    if !moodEntry.quickNote.isEmpty {
                        Spacer(minLength: 2)
                        Text(moodEntry.quickNote)
                            .foregroundStyle(.secondary)
                            .font(.body)
                    }
                }
                .padding()
                .moodRow(
                    accentColor: Color(moodEntry.colorCode),
                    backgroundColor: .white,
                    shadowColor: .black.opacity(0.15)
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

struct ActivityView: View {
    let activities: [Activity]
    var body: some View {
        HStack {
            ForEach(activities) {
                Image(systemName: $0.unselectedIconName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct EntryStackView<MoodEntryContent: View>: View {

    let entries: IdentifiedArrayOf<Entry>
    let moodEntryView: (MoodEntry) -> MoodEntryContent
    
    init(
        entries: IdentifiedArrayOf<Entry>,
        @ViewBuilder moodEntryView: @escaping (MoodEntry) -> MoodEntryContent) {
        self.entries = entries
        self.moodEntryView = moodEntryView
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, content: {
                ForEach(entries) { entry in
                    switch entry {
                    case let .mood(moodEntry):
                        moodEntryView(moodEntry)
                    }
                }
            })
        }
    }
}

#Preview {
    EntryListView(
        store: .init(initialState: EntryListFeature.State(entries: .mockMood())) {
            EntryListFeature()
        }
    )
}

