//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import SwiftUI
import ComposableArchitecture
import Models
import UIComponents
import PersistentClient

public enum ActionResult<Element: Equatable & Identifiable>: Equatable {
  case success(entries: IdentifiedArrayOf<Element>)
  case failure(message: String)
}

@Reducer
public struct EntryListDailyFeature {
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var entries: IdentifiedArrayOf<Entry> = []
    var shouldLoadDataOnAppear = true
    
  }
  
  public enum Action: Equatable {
    case onAppear
    case result(ActionResult<Entry>)
  }
  
  @Dependency(\.persistentClient) var persistentClient
  @Dependency(\.calendar) var calendar
  @Dependency(\.date.now) var now
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .onAppear:
          return .run { send in
            do {
              for try await entries in self.persistentClient.fetchDailyEntries(self.now, self.calendar) {
                await send(.result(.success(entries: entries)))
              }
              
            } catch {
              // TODO. Handle error handling
            }
          }
          
        case let .result(.success(entries)):
          state.entries = entries
          state.shouldLoadDataOnAppear = false
          return .none
          
        case let .result(.failure(message)):
          // TODO. Handle error message
          state.shouldLoadDataOnAppear = false
          return .none
      }
    }
  }
  
}

public struct EntryListDailyView: View {
  
  let store: StoreOf<EntryListDailyFeature>
  
  public init(store: StoreOf<EntryListDailyFeature>) {
    self.store = store
  }
  
  @Dependency(\.formatters) var formatter
  
  public var body: some View {
    ZStack(alignment: .top) {
      Color.tabBar.ignoresSafeArea()
      
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0, content: {
          if let mood = self.store.entries.moodAverage {
            MoodEntryAverageView(
              averageInfo: MoodEntryAverage(
                averageColor: self.store.entries.moodAverageColor,
                entryCount: self.store.entries.count,
                mood: mood
              )
            )
            .padding()
          }

          ForEach(self.store.entries) { entry in
            switch entry {
              case let .mood(moodEntry):
                MoodEntryView(
                  moodEntry: moodEntry,
                  formattedDate: formatter.formatDate(.entryList)(moodEntry.date)
                )
                .moodSingleRow(
                  accentColor: Color(moodEntry.colorCode),
                  backgroundColor: .white
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
          }
        })
      }
      .scrollBounceBehavior(.basedOnSize)
      .safeAreaPadding(.top)
    }
    .task {
      if store.shouldLoadDataOnAppear {
        store.send(.onAppear)
      }
    }
  }
}

#Preview {
  EntryListDailyView(
    store: .init(
      initialState: EntryListDailyFeature.State(),
      reducer: {
        EntryListDailyFeature()
      }
    )
  )
}
