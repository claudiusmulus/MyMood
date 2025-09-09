//
//  SwiftUIView.swift
//
//
//  Created by Alberto Novo Garrido on 2024-02-12.
//

import SwiftUI
import ComposableArchitecture
import Models
import UIComponents
import PersistentClient

public enum ActionDictResult<Element: Equatable & Identifiable>: Equatable {
  case success(entries: Dictionary<Date, IdentifiedArrayOf<Element>>)
  case failure(message: String)
}

@Reducer
public struct EntryListWeeklyFeature {
  
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    var entriesDict: [Date: IdentifiedArrayOf<Entry>] = [:]
    var shouldLoadDataOnAppear = true
    
    var entries: IdentifiedArrayOf<Entry> {
      return Array(entriesDict.values)
        .reduce(into: IdentifiedArrayOf<Entry>()) { partialResult, entryArray in
        partialResult.append(contentsOf: entryArray)
      }
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    case result(ActionDictResult<Entry>)
  }
  
  @Dependency(\.persistentClient) var persistentClient
  @Dependency(\.calendar) var calendar
  @Dependency(\.date.now) var now
  @Dependency(\.formatters.formatDate) var formatDate
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .onAppear:
          guard
            let weekBegginning = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self.now).date,
            let weekEnding = calendar.date(byAdding: .day, value: 7, to: weekBegginning) else {
            return .none
          }
          
          return .run { send in
            do {
              for try await entryDict in await self.persistentClient.fetchWeeklyEntries(weekBegginning, weekEnding, calendar) {
                await send(.result(.success(entries: entryDict)))
              }
            } catch {
              // TODO. Handle error handling
            }
          }
        case let .result(.success(entries)):
//          let formattedEntries = entries.mapKeys(self.formatDate(.entryList(.weeklySection))) { oldArray, newArray in
//            let combineArray = (oldArray + newArray).sorted { $0.date < $1.date }
//            return IdentifiedArrayOf<Entry>(uniqueElements: combineArray)
//          }
          state.entriesDict = entries
          state.shouldLoadDataOnAppear = false
          return .none
          
        case .result(.failure(_)):
          // TODO. Handle error message
          state.shouldLoadDataOnAppear = false
          return .none
      }
    }
  }
  
}

extension Dictionary {
  func mapKeys<T>(_ transform: (Key) throws -> T, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [T: Value] {
    try .init(map { (try transform($0.key), $0.value) }, uniquingKeysWith: combine)
  }
}

struct EntryListWeeklyFeatureView: View {
  
  let store: StoreOf<EntryListWeeklyFeature>
  
  @Dependency(\.formatters) var formatter
  
  init(store: StoreOf<EntryListWeeklyFeature>) {
    self.store = store
  }
  
  var body: some View {
    ZStack(alignment: .top) {
      Color.tabBar.ignoresSafeArea()
      
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
          
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
          
          ForEach(Array(store.entriesDict.keys).sorted(by: >), id: \.self) { keyDate in
            if let entries = store.entriesDict[keyDate],
               !entries.isEmpty {
              sectionEntries(
                entries,
                sectionTitle: formatter.formatDate(.entryList(.weeklySection))(keyDate)
              )
              .padding(.bottom, 20)
            }
          }
        }
      }
      .scrollBounceBehavior(.basedOnSize)
      .safeAreaPadding(.vertical, 10)
    }
    .task {
      if store.shouldLoadDataOnAppear {
        store.send(.onAppear)
      }
    }
  }
  
  @ViewBuilder
  private func sectionEntries(
    _ entries: IdentifiedArrayOf<Entry>,
    sectionTitle: String
  ) -> some View {
    VStack {
      Text(sectionTitle)
        .foregroundStyle(.black)
        .minimumScaleFactor(0.6)
        .lineLimit(1)
        .font(.title3.bold())
        .fontWeight(.heavy)
        .padding([.top, .horizontal])
        .frame(maxWidth: .infinity, alignment: .leading)
        .mask(Rectangle())

      VStack(spacing: 1) {
        ForEach(entries) { entry in
          switch entry {
            case let .mood(moodEntry):
              MoodEntryView(
                moodEntry: moodEntry,
                formattedDate: formatter.formatDate(.entryList(.item))(moodEntry.date)
              )
              .moodSectionRow(
                accentColor: Color(moodEntry.colorCode),
                backgroundColor: .white
              )
          }
        }
      }
      .background(.gray.opacity(0.4))
      .moodSection()
      .padding(.horizontal)
    }
  }
}

#Preview {
  EntryListWeeklyFeatureView(
    store: .init(
      initialState: EntryListWeeklyFeature.State(),
      reducer: {
        EntryListWeeklyFeature()
      },
      withDependencies: { values in
        values.persistentClient.fetchWeeklyEntries = { _, _, _ in
          return AsyncThrowingStream<[Date: IdentifiedArrayOf<Entry>], Error> { continuation in
            continuation.yield([
              .now: .mockMood(),
              Calendar.current.date(byAdding: .day, value: -1, to: .now)!: .mockModGood()
            ])
            continuation.finish()
          }
        }
      }
    )
  )
}
