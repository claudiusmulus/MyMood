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
import CasePaths
import ColorGeneratorClient
import FormattersClient

@Reducer
public struct EntryListFeature {
  
  public init() {}
  
  public struct State: Equatable {
    public var entries: IdentifiedArrayOf<Entry>
    
    var backgroundColor: Color
    
    public init(entries: IdentifiedArrayOf<Entry>) {
      @Dependency(\.date.now) var now
      @Dependency(\.calendar) var calendar
      self.entries = entries
      self.moodEntriesByDate = entries.groupedBy([.month, .year], calendar: calendar)
      let currentMonthComponents = calendar.dateComponents([.month, .year], from: now)
      self.nowMonthDate = calendar.date(from: currentMonthComponents) ?? now
      self.currentMonthDate = self.nowMonthDate
      self.backgroundColor = entries.moodAverageColor
      // By default display the current month entries
      self.visibleMoodEntries = self.moodEntriesByDate[self.currentMonthDate] ?? []
      self.isNextButtonEnabled = self.currentMonthDate < self.nowMonthDate
      self.isPreviousButtonEnabled = self.previousMonthWithEntries(currentMonth: self.currentMonthDate) != nil
    }
    
    public mutating func addEntry(_ entry: Entry) {
      @Dependency(\.calendar) var calendar
      self.entries.insert(entry, at: 0)
      self.moodEntriesByDate = entries.groupedBy([.month, .year], calendar: calendar)
      self.visibleMoodEntries = self.moodEntriesByDate[self.currentMonthDate] ?? []
      self.backgroundColor = self.entries.moodAverageColor
      self.isNextButtonEnabled = self.currentMonthDate < self.nowMonthDate
      self.isPreviousButtonEnabled = self.previousMonthWithEntries(currentMonth: self.currentMonthDate) != nil
    }
    
    // Data
    private var moodEntriesByDate: [Date: IdentifiedArrayOf<MoodEntry>]
    public var currentMonthDate: Date
    public var visibleMoodEntries: IdentifiedArrayOf<MoodEntry>
    let nowMonthDate: Date
    
    public var datesWithEntries: [Date] {
      Array(self.moodEntriesByDate.keys).sorted(by: <)
    }
    
    public func previousMonthWithEntries(currentMonth: Date) -> Date? {
      guard let currentDateIndex = self.datesWithEntries.firstIndex(of: currentMonth),
            currentDateIndex > 0 else {
        return nil
      }
      let previousIndex = self.datesWithEntries.index(before: currentDateIndex)
      return self.datesWithEntries[previousIndex]
    }
    
    public func nextMonthWithEntries(currentMonth: Date) -> Date? {
      guard let currentDateIndex = self.datesWithEntries.firstIndex(of: currentMonth),
            currentDateIndex > 0, currentDateIndex < self.datesWithEntries.count - 1 else {
        return nil
      }
      let previousIndex = self.datesWithEntries.index(before: currentDateIndex)
      return self.datesWithEntries[previousIndex]
    }
    
    var currentMonthDateFormatted: String {
      @Dependency(\.formatters.formatDate) var formatDate
      
      return formatDate(self.currentMonthDate, .monthSelector)
    }
    
    public mutating func updateVisibleEntries(date: Date) {
      self.visibleMoodEntries = self.moodEntriesByDate[date] ?? []
    }
    
    public var isNextButtonEnabled: Bool = false
    
    public var isPreviousButtonEnabled: Bool = false
  }
  
  public enum Action: Equatable {
    case nextMonthButtonTapped
    case previousMonthButtonTapped
  }
  
  @Dependency(\.calendar) var calendar
    
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .nextMonthButtonTapped:
          guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: state.currentMonthDate) else {
            return .none
          }
          state.currentMonthDate = nextMonth
          state.updateVisibleEntries(date: nextMonth)
          state.isNextButtonEnabled = state.currentMonthDate < state.nowMonthDate
          
          return .none
        case .previousMonthButtonTapped:
          guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: state.currentMonthDate) else {
            return .none
          }
          state.currentMonthDate = previousMonth
          state.updateVisibleEntries(date: previousMonth)

          return .none
      }
    }
    ._printChanges()
  }
  
}

extension IdentifiedArray where Element == Entry {
  var moodAverageColor: Color {
    @Dependency(\.colorGenerator) var colorGenerator
    
    guard self.count > 0 else {
      return Color(colorGenerator.generatedColor(amount: 0.5))
    }
    
    let sum = self.compactMap(/Entry.mood).map(\.moodScale).reduce(0, +)
    let moodScaleAverage =  Float(sum) / Float(self.count)
    
    return Color(colorGenerator.generatedColor(amount: moodScaleAverage))
  }
  
  func groupedBy(_ dateComponents: Set<Calendar.Component>, calendar: Calendar) -> [Date: IdentifiedArrayOf<MoodEntry>] {
    let dict: [Date: IdentifiedArrayOf<MoodEntry>] = [:]
    
    return self.compactMap(/Entry.mood).reduce(into: dict) { partialResult, moodEntry in
      let entryDateComponents = calendar.dateComponents(dateComponents, from: moodEntry.date)
      guard let date = calendar.date(from: entryDateComponents) else {
        return
      }
      let current = partialResult[date] ?? []
      partialResult[date] = current + [moodEntry]
    }
  }
}

struct EntryMonthSelector: View {
  
  let store: StoreOf<EntryListFeature>
  
  struct ViewState: Equatable {
    var dates: [Date]
    var selectedDate: Date
    var selectedDateFormatted: String
    var isNextButtonEnabled: Bool
    var isPreviousButtonEnabled: Bool
    var backgroundColor: Color
    
    init(_ state: EntryListFeature.State) {
      self.backgroundColor = state.backgroundColor
      self.dates = state.datesWithEntries
      self.selectedDate = state.currentMonthDate
      self.selectedDateFormatted = state.currentMonthDateFormatted
      self.isNextButtonEnabled = state.isNextButtonEnabled
      self.isPreviousButtonEnabled = state.isPreviousButtonEnabled
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      
      HStack {
        Button(
          action: {
            viewStore.send(.previousMonthButtonTapped, animation: .snappy)
          },
          label: {
            Image(systemName: "chevron.left")
              .font(.title3.bold())
              .foregroundStyle(viewStore.isPreviousButtonEnabled ? .black : .black.opacity(0.3))
          }
        )
        .scaledButton(scaleFactor: 0.9)
        .disabled(!viewStore.isPreviousButtonEnabled)
        .frame(width: 44, height: 44)
        
        Spacer()
        
        Button(
          action: {
            
          },
          label: {
            Text(viewStore.selectedDateFormatted)
              .font(.title3.bold())
          }
        )
        .scaledButton()
        
        Spacer()
        
        Button(
          action: {
            viewStore.send(.nextMonthButtonTapped, animation: .snappy)
          },
          label: {
            Image(systemName: "chevron.right")
              .font(.title3.bold())
              .foregroundStyle(viewStore.isNextButtonEnabled ? .black : .black.opacity(0.3))
          }
        )
        .disabled(!viewStore.isNextButtonEnabled)
        .scaledButton(scaleFactor: 0.9)
        .frame(width: 44, height: 44)
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal)
    }
  }
}




public struct EntryListView: View {
  
  let store: StoreOf<EntryListFeature>
  public init(store: StoreOf<EntryListFeature>) {
    self.store = store
  }
  
  struct ViewState: Equatable {
    var moodEntries: IdentifiedArrayOf<MoodEntry>
    var backgroundColor: Color
    
    init(_ state: EntryListFeature.State) {
      self.moodEntries = state.visibleMoodEntries
      self.backgroundColor = state.backgroundColor
    }
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      
      ZStack(alignment: .top) {
        viewStore.backgroundColor.ignoresSafeArea()
        
        VStack {
          EntryMonthSelector(store: self.store)
          
          EntryStackView(entries: viewStore.moodEntries) { moodEntry in
            HStack(alignment: .firstTextBaseline) {
              VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                  Text(moodEntry.mood.title)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .font(.title3.bold())
                }
                if !moodEntry.activities.isEmpty {
                  ActivityView(activities: Array(moodEntry.activities.prefix(3)))
                }
                
                if !moodEntry.observations.isEmpty {
                  Text(moodEntry.observations)
                    .lineLimit(2)
                    .foregroundStyle(.black)
                    .font(.caption)
                    .padding(.top, 2)
                }
                
              }
              Spacer()
              VStack {
                VStack(alignment: .trailing) {
                  Text(moodEntry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.body)
                    .foregroundStyle(.black)
                  
                  if let weatherEntry = moodEntry.weatherEntry {
                    Image(systemName: weatherEntry.selectedIcon)
                      .font(.title2)
                      .foregroundStyle(.black)
                      .padding(.top, 1)
                    
                  }
                }
              }
            }
            .padding()
            .moodRow(
              accentColor: Color(moodEntry.colorCode),
              backgroundColor: .white,
              moodScale: moodEntry.moodScale,
              shadowColor: .black.opacity(0.15)
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
          }
          
        }
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
          .foregroundStyle(.black)
      }
    }
  }
}

struct EntryStackView<Element: Identifiable, MoodEntryContent: View>: View {
  
  let entries: IdentifiedArrayOf<Element>
  let content: (Element) -> MoodEntryContent
  
  init(
    entries: IdentifiedArrayOf<Element>,
    @ViewBuilder content: @escaping (Element) -> MoodEntryContent) {
      self.entries = entries
      self.content = content
    }
  
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0, content: {
        ForEach(self.entries, content: content)
//        ForEach(entries) { entry in
//          switch entry {
//            case let .mood(moodEntry):
//              moodEntryView(moodEntry)
//          }
//        }
      })
    }
    .scrollBounceBehavior(.basedOnSize)
  }
}

#Preview {
  EntryListView(
    store: .init(initialState: EntryListFeature.State(entries: .mockModGood())) {
      EntryListFeature()
    }
  )
}

