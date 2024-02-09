//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-05.
//

import SwiftUI
import ComposableArchitecture
import FormattersClient

@Reducer
struct MonthSelectorFeature {
  
  @ObservableState
  struct State: Equatable {
    let currentDate: Date
    let selectedDate: Date
    
    private(set) var availableYears: [Year]
    var selectedYear: Year?
    var advancedYearButtonEnabled = false
    var backYearButtonEnabled = false
    
    init(
      currentDate: Date,
      selectedDate: Date,
      entryDates: [Date]
    ) {
      @Dependency(\.formatters) var formatters
      @Dependency(\.uuid) var uuid
      @Dependency(\.calendar) var calendar
      
      self.currentDate = currentDate
      self.selectedDate = selectedDate
      self.availableYears = entryDates.sorted(by: <).groupByYear(
        now: currentDate,
        calendar: calendar,
        uuid: { uuid() },
        formatYear: formatters.formatDate(.monthSelector(.yearTitle)),
        generateMonth: formatters.generateDate(.monthSelector),
        formatMonth: formatters.formatDate(.monthSelector(.monthTitle))
      )
    }
    
    struct Year: Identifiable, Equatable, Hashable {
      var id: UUID
      var shortSymbol: String
      var date: Date
      var months: [SelectableMonth]
      
      func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
      }
      
      static func with(
        now: Date,
        year: Date,
        month: Date,
        calendar: Calendar,
        uuid: () -> UUID,
        formatYear: @escaping (Date) -> String,
        generateMonth: @escaping (String) -> Date?,
        formatMonth: @escaping (Date) -> String
      ) -> Year {
        let months = calendar.monthSymbols.compactMap { symbol -> SelectableMonth?  in
          let year = Calendar.current.component(.year, from: year)
          guard let symbolDate = generateMonth(symbol + "/\(year)") else {
            return nil
          }
          
          let isMonthDateEnabled = calendar.isDate(symbolDate, equalTo: month, toGranularity: .month)
          let isCurrentMonth = calendar.isDate(symbolDate, equalTo: now, toGranularity: .month)
          
          return SelectableMonth(
            id: uuid(),
            date: symbolDate,
            shortSymbol: formatMonth(symbolDate),
            isEnabled: isMonthDateEnabled,
            isCurrent: isCurrentMonth
          )
        }
        
        return Year(
          id: uuid(),
          shortSymbol: formatYear(year),
          date: year,
          months: months
        )
      }
      
      func addMonth(
        _ month: Date,
        calendar: Calendar
      ) -> Year {
        var months = self.months
        
        guard let selectedMonthIndex = months.firstIndex(where: {
          calendar.isDate($0.date, equalTo: month, toGranularity: .month) && !$0.isEnabled
        }) else {
          return self
        }
        
        var currentMonth = months[selectedMonthIndex]
        currentMonth.isEnabled = true
        
        months[selectedMonthIndex] = currentMonth
        
        return Year(id: self.id, shortSymbol: self.shortSymbol, date: self.date, months: months)
      }
    }
    
    struct SelectableMonth: Identifiable, Equatable {
      var id: UUID
      var date: Date
      var shortSymbol: String
      var isEnabled: Bool
      var isCurrent: Bool
    }
  }
  
  enum Action: BindableAction {
    case advancedYearButtonTapped
    case backYearButtonTapped
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case onAppear
    case selectMonth(MonthSelectorFeature.State.SelectableMonth)
    
    enum Delegate {
      case selectMonthDate(Date)
    }
  }
  
  @Dependency(\.calendar) var calendar
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .advancedYearButtonTapped:
          
          guard let selectedYear = state.selectedYear,
                let selectedYearIndex = state.availableYears.firstIndex(where: { $0.id == selectedYear.id }),
                selectedYearIndex < state.availableYears.count - 1 else {
            return .none
          }
          let newIndex = selectedYearIndex + 1
          state.selectedYear = state.availableYears[newIndex]
          state.advancedYearButtonEnabled = newIndex < state.availableYears.count - 1
          state.backYearButtonEnabled = newIndex > 0
          
          return .none
          
        case .backYearButtonTapped:
          
          guard let selectedYear = state.selectedYear,
                let selectedYearIndex = state.availableYears.firstIndex(where: { $0.id == selectedYear.id }),
                selectedYearIndex > 0 else {
            return .none
          }
          let newIndex = selectedYearIndex - 1
          state.selectedYear = state.availableYears[newIndex]
          state.advancedYearButtonEnabled = newIndex < state.availableYears.count - 1
          state.backYearButtonEnabled = newIndex > 0
          
          return .none
          
        case .binding:
          return .none
          
        case .delegate:
          return .none
          
        case .onAppear:
          guard let selectedYearIndex = state.availableYears.firstIndex(where: {
            calendar.isDate($0.date, equalTo: state.selectedDate, toGranularity: .year)
          }) else {
            return .none
          }
          
          state.advancedYearButtonEnabled = selectedYearIndex < state.availableYears.count - 1
          state.backYearButtonEnabled = selectedYearIndex > 0
          state.selectedYear = state.availableYears[selectedYearIndex]
          
          return .none
          
        case let .selectMonth(month):
          return .run { send in
            await send(.delegate(.selectMonthDate(month.date)))
          }
      }
    }
  }
}

struct MonthSelectorView: View {
  
  @State var store: StoreOf<MonthSelectorFeature>
  
  var body: some View {
    
    VStack {
      
      HStack(spacing: 10) {
        if let currentYear = store.selectedYear?.shortSymbol {
          Text(currentYear)
            .font(.title2)
        }
        Spacer()
        
        Button(
          action: {
            store.send(.backYearButtonTapped, animation: .snappy)
          },
          label: {
            Image(systemName: "chevron.left")
              .font(.title3.bold())
              .foregroundStyle(store.backYearButtonEnabled ? .black : .black.opacity(0.3))
          }
        )
        .scaledButton(scaleFactor: 0.9)
        .disabled(!store.backYearButtonEnabled)
        .frame(width: 30, height: 44)
        
        Button(
          action: {
            store.send(.advancedYearButtonTapped, animation: .snappy)
          },
          label: {
            Image(systemName: "chevron.right")
              .font(.title3.bold())
              .foregroundStyle(store.advancedYearButtonEnabled ? .black : .black.opacity(0.3))
          }
        )
        .scaledButton(scaleFactor: 0.9)
        .disabled(!store.advancedYearButtonEnabled)
        .frame(width: 30, height: 44)
        
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal)
      
      ScrollView(.horizontal) {
        LazyHStack(spacing: 0) {
          ForEach(store.availableYears) { year in
            YearView(year: year)
              .id(year)
              .padding(.horizontal)
              .containerRelativeFrame(.horizontal)
              .frame(maxHeight: .infinity, alignment: .top)
          }
        }
      }
      .scrollTargetLayout()
      .scrollPosition(id: $store.selectedYear)
      .scrollIndicators(.hidden)
      .scrollTargetBehavior(.paging)
      .frame(height: 250)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .onAppear {
      store.send(.onAppear)
    }

  }

}

struct YearView: View {
  let year: MonthSelectorFeature.State.Year
  var body: some View {
    
    LazyVGrid(
      columns: Array(repeating: GridItem(), count: 4),
      spacing: 10,
      content: {
        ForEach(year.months) { month in
          VStack {
            Button(
              action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/,
              label: {
                Text(month.shortSymbol)
                  .frame(maxWidth: .infinity)
                  .foregroundStyle(month.isEnabled ? month.isCurrent ? .white : .black : .black.opacity(0.2))
                  .padding(.horizontal)
            })
            .primaryButton(backgroundStyle: month.isCurrent ? .black : .black.opacity(0.2))
          }
        }
      })
  }
}

extension Array where Element == Date {
  static func mock(referenceDate: Date, calendar: Calendar) -> Self {
    [
      referenceDate,
      calendar.date(byAdding: .month, value: -1, to: referenceDate)!,
      calendar.date(byAdding: .year, value: -1, to: referenceDate)!
    ]
  }
}

#Preview {
  MonthSelectorView(
    store: Store(
      initialState: MonthSelectorFeature.State(
        currentDate: .now,
        selectedDate: .now,
        entryDates: .mock(referenceDate: .now, calendar: Calendar.current)
      ),
      reducer: {
        MonthSelectorFeature()
      }, 
      withDependencies: { dependencyValues in
        
      }
    )
  )
}

extension Array where Element == MonthSelectorFeature.State.Year {
  func current(_ date: Date, calendar: Calendar) -> Element? {
    self.first {
      calendar.isDate($0.date, equalTo: date, toGranularity: .year)
    }
  }
}

extension Array where Element == Date {
  
  func groupByYear(
    now: Date,
    calendar: Calendar,
    uuid: () -> UUID,
    formatYear: @escaping (Date) -> String,
    generateMonth: @escaping (String) -> Date?,
    formatMonth: @escaping (Date) -> String
  ) -> [MonthSelectorFeature.State.Year] {
        
    let result: [MonthSelectorFeature.State.Year] = []
    
    return self.reduce(into: result) { partialResult, newDate in
      
      let newDateYearComponents = calendar.dateComponents([.year], from: newDate)
      let newDateYearMonthComponents = calendar.dateComponents([.month, .year], from: newDate)
      
      guard let yearDate = calendar.date(from: newDateYearComponents),
            let yearMonthDate = calendar.date(from: newDateYearMonthComponents) else {
        return
      }
      
      if let currentYearIndex = partialResult.firstIndex(where: { year in
        year.date == yearDate
      }) {
        let currentYear = partialResult[currentYearIndex]
        let updatedYear = currentYear.addMonth(yearMonthDate, calendar: calendar)
        partialResult[currentYearIndex] = updatedYear
      } else {
        partialResult.append(
          .with(
            now: now,
            year: yearDate,
            month: yearMonthDate,
            calendar: calendar,
            uuid: uuid,
            formatYear: formatYear,
            generateMonth: generateMonth,
            formatMonth: formatMonth
          )
        )
      }
      
    }
  }
}
