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
import PersistentClient

@Reducer
public struct EntryListFeature {
  
  public init() {}
  
  public struct State: Equatable {
    
    public struct SectionEntryValue: Equatable {
      var entries: IdentifiedArrayOf<Entry>
      var formattedDate: String
      var averageColor: Color
      
      public init(entries: IdentifiedArrayOf<Entry>, formattedDate: String, averageColor: Color) {
        self.entries = entries
        self.formattedDate = formattedDate
        self.averageColor = averageColor
      }
    }
    
    public init() {
      @Dependency(\.date.now) var now
      @Dependency(\.calendar) var calendar
      let currentMonthComponents = calendar.dateComponents([.month, .year], from: now)
      self.nowMonthDate = calendar.date(from: currentMonthComponents) ?? now
      self.currentMonthDate = self.nowMonthDate
    }
    
    mutating func addEntries(_ entries: IdentifiedArrayOf<Entry>) {
      @Dependency(\.calendar) var calendar
      @Dependency(\.formatters) var formatters
      self.entriesByDate = entries.groupedBy(
        dateComponents: [.month, .year],
        sectionDateComponents: [.day, .month, .year],
        calendar: calendar,
        formatter: formatters.formatDate(.entryList)
      )
    }
    
    public mutating func addEntry(_ entry: Entry) {
      @Dependency(\.calendar) var calendar
      @Dependency(\.formatters) var formatters
      
      self.entriesByDate.appendEntry(
        entry,
        calendar: calendar,
        formatter: formatters.formatDate(.entryList)
      )
    }
    
    // Data
    public var entriesByDate: [Date: [Date: SectionEntryValue]] = [:] {
      didSet {
        self.visibleEntries = self.entriesByDate[self.currentMonthDate] ?? [:]
        self.isNextButtonEnabled = self.currentMonthDate < self.nowMonthDate
        self.isPreviousButtonEnabled = self.previousMonthWithEntries(currentMonth: self.currentMonthDate) != nil
      }
    }
    public var currentMonthDate: Date
    public var visibleEntries: [Date: SectionEntryValue] = [:]
    public var nowMonthDate: Date
    public var isDataFetched: Bool = false
    public var isNextButtonEnabled: Bool = false
    public var isPreviousButtonEnabled: Bool = false
    
    private var datesWithEntries: [Date] {
      Array(self.entriesByDate.keys).sorted(by: <)
    }
    
    func previousMonthWithEntries(currentMonth: Date) -> Date? {
      guard let currentDateIndex = self.datesWithEntries.firstIndex(of: currentMonth),
            currentDateIndex > 0 else {
        return nil
      }
      let previousIndex = self.datesWithEntries.index(before: currentDateIndex)
      return self.datesWithEntries[previousIndex]
    }
    
    func nextMonthWithEntries(currentMonth: Date) -> Date? {
      guard let currentDateIndex = self.datesWithEntries.firstIndex(of: currentMonth),
            currentDateIndex < self.datesWithEntries.count - 1 else {
        return nil
      }
      let nextIndex = self.datesWithEntries.index(after: currentDateIndex)
      return self.datesWithEntries[nextIndex]
    }
    
    var currentMonthDateFormatted: String {
      @Dependency(\.formatters.formatDate) var formatDate
      
      return formatDate(.monthSelector)(self.currentMonthDate)
    }
    
    mutating func updateVisibleEntries(date: Date) {
      self.visibleEntries = self.entriesByDate[date] ?? [:]
      self.isNextButtonEnabled = self.currentMonthDate < self.nowMonthDate
      self.isPreviousButtonEnabled = self.previousMonthWithEntries(currentMonth: self.currentMonthDate) != nil
    }
  }
  
  public enum Action: Equatable {
    case nextMonthButtonTapped
    case previousMonthButtonTapped
    case onAppear
    case fetchedEntriesSuccess(IdentifiedArrayOf<Entry>)
    case fetchedEntriesFailure(String)
  }
  
  @Dependency(\.calendar) var calendar
  @Dependency(\.persistentClient) var persistentClient
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case let .fetchedEntriesSuccess(entries):
          state.addEntries(entries)
          state.isDataFetched = true
          return .none
        case .fetchedEntriesFailure:
          state.isDataFetched = true
          return .none
        case .nextMonthButtonTapped:
          guard let nextMonth = state.nextMonthWithEntries(currentMonth: state.currentMonthDate) else {
            return .none
          }
          state.currentMonthDate = nextMonth
          state.updateVisibleEntries(date: nextMonth)
          
          return .none
        case .onAppear:
          return .run { send in
            do {
              let entries = try self.persistentClient.fetchEntries(nil)
              
              await send(.fetchedEntriesSuccess(entries))
              
            } catch {
              
            }
            
          }
        case .previousMonthButtonTapped:
          guard let previousMonth = state.previousMonthWithEntries(currentMonth: state.currentMonthDate) else {
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

struct EntryMonthSelector: View {
  
  let store: StoreOf<EntryListFeature>
  @Binding var showMonthOptions: Bool
  
  struct ViewState: Equatable {
    var dates: [Date]
    var selectedDate: Date
    var selectedDateFormatted: String
    var isNextButtonEnabled: Bool
    var isPreviousButtonEnabled: Bool
    
    init(_ state: EntryListFeature.State) {
      self.dates = Array(state.entriesByDate.keys)
      self.selectedDate = state.currentMonthDate
      self.selectedDateFormatted = state.currentMonthDateFormatted
      self.isNextButtonEnabled = state.isNextButtonEnabled
      self.isPreviousButtonEnabled = state.isPreviousButtonEnabled
    }
  }
  
  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      
      ZStack(alignment: .top) {
        
        contentBackground()
          .onTapGesture {
            withAnimation(.snappy) {
              self.showMonthOptions = false
            }
          }
        
        VStack(spacing: 0) {
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
                withAnimation(.snappy) {
                  self.showMonthOptions.toggle()
                }
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
          .padding(.bottom, 10)
          
          Color(red: 0.82, green: 0.84, blue: 0.86)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
        }
        .background(.tabBar)
        .zIndex(2.0)
        
        if self.showMonthOptions {
          Rectangle()
            .fill(.orange)
            .frame(height: 200)
            .zIndex(1.0)
            .transition(.move(edge: .top))
        }
      }
      
    }
  }
  
  @ViewBuilder
  private func contentBackground(fill: some ShapeStyle = .ultraThinMaterial) -> some View {
    Rectangle()
      .fill(fill)
      .opacity(0.9)
      .ignoresSafeArea()
      .animation(.smooth) {
        $0.opacity(self.showMonthOptions ? 1 : 0)
      }
  }
}

public struct MoodEntryView: View {
  let moodEntry: MoodEntry
  let formattedDate: String?
  
  public var body: some View {
    
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 5) {
        
        if let formattedDate {
          Text(formattedDate)
            .font(.body)
            .foregroundStyle(.black)
        }
        
        Text(moodEntry.mood.title)
          .minimumScaleFactor(0.6)
          .foregroundStyle(Color(moodEntry.colorCode))
          .lineLimit(1)
          .font(.title3.bold())
        
        if !moodEntry.activities.isEmpty {
          ActivityView(activities: Array(moodEntry.activities.prefix(3)))
        }
        
        if let notes = moodEntry.observations, !notes.isEmpty {
          Text(notes)
            .lineLimit(2)
            .foregroundStyle(.black)
            .font(.caption)
            .padding(.top, 2)
        }
        
      }
      
      if let weatherEntryIconName = moodEntry.weatherEntry?.selectedIcon {
        Spacer()
        
        Image(systemName: weatherEntryIconName)
          .font(.title2)
          .foregroundStyle(.black)
          .padding(.trailing, 10)
      }
    }
  }
}

public struct MoodEntrySectionView: View {
  
  let date: String
  let entries: IdentifiedArrayOf<Entry>
  let sectionColor: Color
  
  public var body: some View {
    VStack(spacing: 0) {
      Text(date)
        .font(.title3.bold())
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(sectionColor)
      
      VStack(spacing: 1) {
        ForEach(self.entries) { entry in
          switch entry {
            case let .mood(moodEntry):
              MoodEntryView(moodEntry: moodEntry, formattedDate: nil)
                .padding()
                .moodSectionRow(
                  accentColor: Color(moodEntry.colorCode),
                  backgroundColor: .white,
                  dividerColor: sectionColor
                )
          }
        }
      }
    }
  }
}

public struct EntryListView: View {
  
  let store: StoreOf<EntryListFeature>
  @Binding private var showExtraContentActions: Bool
  
  public init(
    store: StoreOf<EntryListFeature>,
    showExtraContentActions: Binding<Bool>
  ) {
    self.store = store
    self._showExtraContentActions = showExtraContentActions
  }
  
  struct ViewState: Equatable {
    var moodEntries: [Date: EntryListFeature.State.SectionEntryValue]
    var sections: [Date]
    var isDataFetched: Bool
    
    init(_ state: EntryListFeature.State) {
      self.moodEntries = state.visibleEntries
      self.sections = Array(self.moodEntries.keys).sorted(by: >)
      self.isDataFetched = state.isDataFetched
    }
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      
      ZStack(alignment: .top) {
        Color.tabBar.ignoresSafeArea()
        
        EntryMonthSelector(store: self.store, showMonthOptions: self.$showExtraContentActions)
          .zIndex(2.0)
        
        EntryStackView(
          entries: viewStore.moodEntries,
          singleContent: { date, entry in
            switch entry {
              case let .mood(moodEntry):
                MoodEntryView(moodEntry: moodEntry, formattedDate: date)
                  .padding()
                  .moodSingleRow(
                    accentColor: Color(moodEntry.colorCode),
                    backgroundColor: .white
                  )
                  .padding(.horizontal)
                  .padding(.vertical, 8)
            }
          },
          sectionContent: { date, entries, color in
            MoodEntrySectionView(date: date, entries: entries, sectionColor: color)
              .moodSection()
              .padding(.horizontal)
              .padding(.top, 2)
          }
        )
        .padding(.top, 54)
        
      }
      .task {
        if !viewStore.isDataFetched {
          viewStore.send(.onAppear)
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

struct EntryStackView<MoodEntrySingleContent: View, MoodEntrySectionContent: View>: View {
  
  let entries: [Date: EntryListFeature.State.SectionEntryValue]
  let sections: [Date]
  let sectionContent: (String, IdentifiedArrayOf<Entry>, Color) -> MoodEntrySectionContent
  let singleContent: (String, Entry) -> MoodEntrySingleContent
  
  init(
    entries: [Date: EntryListFeature.State.SectionEntryValue],
    @ViewBuilder singleContent: @escaping (String, Entry) -> MoodEntrySingleContent,
    @ViewBuilder sectionContent: @escaping (String, IdentifiedArrayOf<Entry>, Color) -> MoodEntrySectionContent
  ) {
    self.entries = entries
    self.sections = Array(entries.keys).sorted(by: >)
    self.sectionContent = sectionContent
    self.singleContent = singleContent
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 10, content: {
        ForEach(self.sections, id: \.self) { section in
          if let entrySection = self.entries[section], !entrySection.entries.isEmpty {
            if entrySection.entries.count == 1 {
              singleContent(entrySection.formattedDate, entrySection.entries[0])
            } else {
              sectionContent(entrySection.formattedDate, entrySection.entries, entrySection.averageColor)
            }
          }
        }
      })
    }
    .scrollBounceBehavior(.basedOnSize)
    .safeAreaPadding(.top)
  }
}

#Preview {
  EntryListView(
    store: .init(
      initialState: EntryListFeature.State(),
      reducer: {
        EntryListFeature()
      },
      withDependencies: {
        $0.persistentClient.fetchEntries = { _ in .mockModGood() }
      }),
    showExtraContentActions: .constant(false)
  )
}

