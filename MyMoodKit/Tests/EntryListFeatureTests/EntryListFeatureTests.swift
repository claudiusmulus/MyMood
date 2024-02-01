//
//  EntryListFeatureTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-11.
//

import XCTest
import ComposableArchitecture
import EntryListFeature
import SwiftUI

@MainActor
final class EntryListFeatureTests: XCTestCase {

  // Test load entries
  
  func testAppearWithNoEntriesStored() async {
    let calendar = Calendar(identifier: .gregorian)
    
    let store = TestStoreOf<EntryListFeature>(
      initialState: EntryListFeature.State(),
      reducer: {
        EntryListFeature()
      }) {
        $0.calendar = calendar
        $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
        $0.persistentClient.fetchEntries = { _ in [] }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "Wednesday, Jan 30" }
            default:
              return { _ in
                return ""
              }
          }
        }
      }
    
    await store.send(.onAppear)
    
    let expectedDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: Date(timeIntervalSince1970: 1_234_567_890)
      )
    
    await store.receive(\.fetchedEntriesSuccess) { state in
      state.currentMonthDate = calendar.date(from: expectedDateComponents)!
      state.nowMonthDate = calendar.date(from: expectedDateComponents)!
      state.entriesByDate = [:]
      state.visibleEntries = [:]
      state.isDataFetched = true
      state.isNextButtonEnabled = false
      state.isPreviousButtonEnabled = false
    }
    
  }
  
  func testAppearWithSameDateEntriesAndCurrentMonth() async {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date(timeIntervalSince1970: 1_234_567_890)
    
    let store = TestStoreOf<EntryListFeature>(
      initialState: EntryListFeature.State(),
      reducer: {
        EntryListFeature()
      }) {
        $0.calendar = calendar
        $0.date.now = currentDate
        $0.persistentClient.fetchEntries = { _ in
          [
            .mood(.mock(id: 1, date: calendar.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 2, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 3, date: currentDate))
          ]
        }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "Wednesday, Jan 30" }
            default:
              return { _ in
                return ""
              }
          }
        }
        $0.colorGenerator.generatedColor = { _ in
            .init(red: 1, green: 1, blue: 1)
        }
      }
    
    await store.send(.onAppear)
    
    let expectedDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: currentDate
      )
    
    let expectedSectionDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: currentDate
      )
    
    guard let expectedCurrentDate = calendar.date(from: expectedDateComponents),
            let expectedSectionDate = calendar.date(from: expectedSectionDateComponents) else {
      XCTFail("Wrong dates")
      return
    }
    
    let expectedSectionEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 1, date: calendar.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate)),
        .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 2, to: currentDate) ?? currentDate)),
        .mood(.mock(id: 3, date: currentDate))
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    await store.receive(\.fetchedEntriesSuccess) { state in
      state.currentMonthDate = expectedCurrentDate
      state.nowMonthDate = expectedCurrentDate
      state.entriesByDate = [expectedCurrentDate: [expectedSectionDate: expectedSectionEntry]]
      state.visibleEntries = [expectedSectionDate: expectedSectionEntry]
      state.isDataFetched = true
      state.isNextButtonEnabled = false
      state.isPreviousButtonEnabled = false
    }
    
  }
  
  func testAppearWithDifferentDateEntriesAndCurrentMonth() async {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date(timeIntervalSince1970: 1_234_567_890)
    
    let store = TestStoreOf<EntryListFeature>(
      initialState: EntryListFeature.State(),
      reducer: {
        EntryListFeature()
      }) {
        $0.calendar = calendar
        $0.date.now = currentDate
        $0.persistentClient.fetchEntries = { _ in
          [
            .mood(.mock(id: 1, date: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 3, date: currentDate))
          ]
        }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "Wednesday, Jan 30" }
            default:
              return { _ in
                return ""
              }
          }
        }
        $0.colorGenerator.generatedColor = { _ in
            .init(red: 1, green: 1, blue: 1)
        }
      }
    
    await store.send(.onAppear)
    
    let expectedDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: currentDate
      )
    
    let expectedSectionDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
      )
    
    let expectedSingleDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: currentDate
      )
    
    guard let expectedCurrentDate = calendar.date(from: expectedDateComponents),
          let expectedSectionDate = calendar.date(from: expectedSectionDateComponents),
            let expectedSingleDate = calendar.date(from: expectedSingleDateComponents) else {
      XCTFail("Wrong dates")
      return
    }
    
    let expectedSectionEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 1, date: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)),
        .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate)),
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    let expectedSingleEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 3, date: currentDate))
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    await store.receive(\.fetchedEntriesSuccess) { state in
      state.currentMonthDate = expectedCurrentDate
      state.nowMonthDate = expectedCurrentDate
      state.entriesByDate = [
        expectedCurrentDate: [
          expectedSectionDate: expectedSectionEntry,
          expectedSingleDate: expectedSingleEntry
        ]
      ]
      state.visibleEntries = [
        expectedSectionDate: expectedSectionEntry,
        expectedSingleDate: expectedSingleEntry
      ]
      state.isDataFetched = true
      state.isNextButtonEnabled = false
      state.isPreviousButtonEnabled = false
    }
    
  }
  
  func testAppearWithDifferentDateEntriesAndDifferentMonth() async {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date(timeIntervalSince1970: 1_234_567_890)
    
    let store = TestStoreOf<EntryListFeature>(
      initialState: EntryListFeature.State(),
      reducer: {
        EntryListFeature()
      }) {
        $0.calendar = calendar
        $0.date.now = currentDate
        $0.persistentClient.fetchEntries = { _ in
          [
            .mood(.mock(id: 1, date: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 3, date: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 4, date: currentDate))
          ]
        }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "Wednesday, Jan 30" }
            default:
              return { _ in
                return ""
              }
          }
        }
        $0.colorGenerator.generatedColor = { _ in
            .init(red: 1, green: 1, blue: 1)
        }
      }
    
    await store.send(.onAppear)
    
    let expectedDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: currentDate
      )
    
    let expectedPreviousMonthDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate
      )
    
    let expectedPreviousMonthSingleDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate
      )
    
    let expectedSectionDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate
      )
    
    let expectedSingleDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: currentDate
      )
    
    guard let expectedCurrentDate = calendar.date(from: expectedDateComponents),
          let expectedPreviousMonthDate = calendar.date(from: expectedPreviousMonthDateComponents),
          let expectedPreviousMonthSingleDate = calendar.date(from: expectedPreviousMonthSingleDateComponents),
          let expectedSectionDate = calendar.date(from: expectedSectionDateComponents),
          let expectedSingleDate = calendar.date(from: expectedSingleDateComponents) else {
      XCTFail("Wrong dates")
      return
    }
    
    let expectedSectionEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate)),
        .mood(.mock(id: 3, date: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)),
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    let expectedSingleEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 4, date: currentDate))
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    let expectedPreviousMonthEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 1, date: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate))
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    await store.receive(\.fetchedEntriesSuccess) { state in
      state.currentMonthDate = expectedCurrentDate
      state.nowMonthDate = expectedCurrentDate
      state.entriesByDate = [
        expectedPreviousMonthDate: [expectedPreviousMonthSingleDate: expectedPreviousMonthEntry],
        expectedCurrentDate: [
          expectedSectionDate: expectedSectionEntry,
          expectedSingleDate: expectedSingleEntry
        ]
      ]
      state.visibleEntries = [
        expectedSectionDate: expectedSectionEntry,
        expectedSingleDate: expectedSingleEntry
      ]
      state.isDataFetched = true
      state.isNextButtonEnabled = false
      state.isPreviousButtonEnabled = true
    }
    
  }
  
  // Func test navigate between months
  func testShowPreviousMonthEntriesAndBack() async {
    
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date(timeIntervalSince1970: 1_234_567_890)
    
    let store = TestStoreOf<EntryListFeature>(
      initialState: EntryListFeature.State(),
      reducer: {
        EntryListFeature()
      }) {
        $0.calendar = calendar
        $0.date.now = currentDate
        $0.persistentClient.fetchEntries = { _ in
          [
            .mood(.mock(id: 1, date: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 3, date: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)),
            .mood(.mock(id: 4, date: currentDate))
          ]
        }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "Wednesday, Jan 30" }
            default:
              return { _ in
                return ""
              }
          }
        }
        $0.colorGenerator.generatedColor = { _ in
            .init(red: 1, green: 1, blue: 1)
        }
      }
    
    await store.send(.onAppear)
    
    let expectedDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: currentDate
      )
    
    let expectedPreviousMonthDateComponents = calendar
      .dateComponents(
        [.month, .year],
        from: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate
      )
    
    let expectedPreviousMonthSingleDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate
      )
    
    let expectedSectionDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate
      )
    
    let expectedSingleDateComponents = calendar
      .dateComponents(
        [.day, .month, .year],
        from: currentDate
      )
    
    guard let expectedCurrentDate = calendar.date(from: expectedDateComponents),
          let expectedPreviousMonthDate = calendar.date(from: expectedPreviousMonthDateComponents),
          let expectedPreviousMonthSingleDate = calendar.date(from: expectedPreviousMonthSingleDateComponents),
          let expectedSectionDate = calendar.date(from: expectedSectionDateComponents),
          let expectedSingleDate = calendar.date(from: expectedSingleDateComponents) else {
      XCTFail("Wrong dates")
      return
    }
    
    let expectedSectionEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 2, date: calendar.date(byAdding: .hour, value: 26, to: currentDate) ?? currentDate)),
        .mood(.mock(id: 3, date: calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate)),
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    let expectedSingleEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 4, date: currentDate))
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    let expectedPreviousMonthEntry = EntryListFeature.State.SectionEntryValue(
      entries: [
        .mood(.mock(id: 1, date: calendar.date(byAdding: .month, value: -2, to: currentDate) ?? currentDate))
      ],
      formattedDate: "Wednesday, Jan 30",
      averageColor: Color(Color.Resolved(red: 1, green: 1, blue: 1))
    )
    
    await store.receive(\.fetchedEntriesSuccess) { state in
      state.currentMonthDate = expectedCurrentDate
      state.nowMonthDate = expectedCurrentDate
      state.entriesByDate = [
        expectedPreviousMonthDate: [expectedPreviousMonthSingleDate: expectedPreviousMonthEntry],
        expectedCurrentDate: [
          expectedSectionDate: expectedSectionEntry,
          expectedSingleDate: expectedSingleEntry
        ]
      ]
      state.visibleEntries = [
        expectedSectionDate: expectedSectionEntry,
        expectedSingleDate: expectedSingleEntry
      ]
      state.isDataFetched = true
      state.isNextButtonEnabled = false
      state.isPreviousButtonEnabled = true
    }
    
    await store.send(.previousMonthButtonTapped) { state in
      state.currentMonthDate = expectedPreviousMonthDate
      state.visibleEntries = [expectedPreviousMonthSingleDate: expectedPreviousMonthEntry]
      state.isNextButtonEnabled = true
      state.isPreviousButtonEnabled = false
    }
    
    await store.send(.previousMonthButtonTapped)
    
    await store.send(.nextMonthButtonTapped) { state in
      state.currentMonthDate = expectedCurrentDate
      state.visibleEntries = [
        expectedSectionDate: expectedSectionEntry,
        expectedSingleDate: expectedSingleEntry
      ]
      state.isNextButtonEnabled = false
      state.isPreviousButtonEnabled = true
    }
    
  }
  
}
