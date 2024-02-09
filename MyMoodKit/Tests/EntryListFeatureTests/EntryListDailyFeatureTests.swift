//
//  EntryListDailyFeatureTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import XCTest
import ComposableArchitecture
@testable import EntryListFeature
import Models
import SwiftUI

@MainActor
final class EntryListDailyFeatureTests: XCTestCase {

  // Test load entries.
  func testAppearWithNoEntriesStored() async {
    let calendar = Calendar(identifier: .gregorian)
    
    let store = TestStoreOf<EntryListDailyFeature>(
      initialState: EntryListDailyFeature.State(),
      reducer: {
        EntryListDailyFeature()
      },
      withDependencies: {
        $0.calendar = calendar
        $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
        $0.persistentClient.fetchDailyEntries = { _, _ in
          return AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> { continuation in
            continuation.yield([])
            continuation.finish()
          }
        }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "3:00 pm" }
            default:
              return { _ in
                return ""
              }
          }
        }
      }
    )
    
    await store.send(.onAppear)
    
    await store.receive(\.result) { state in
      state.entries = []
      state.shouldLoadDataOnAppear = false
    }
  }
  
  func testAppearWithEntriesStored() async {
    let calendar = Calendar(identifier: .gregorian)
    
    let store = TestStoreOf<EntryListDailyFeature>(
      initialState: EntryListDailyFeature.State(),
      reducer: {
        EntryListDailyFeature()
      },
      withDependencies: {
        $0.calendar = calendar
        $0.date.now = Date(timeIntervalSince1970: 1_234_567_890)
        $0.uuid = .incrementing
        $0.persistentClient.fetchDailyEntries = { _, _ in
          return AsyncThrowingStream<IdentifiedArrayOf<Entry>, Error> { continuation in
            continuation.yield(
              [
                .mood(.mock(id: 1, date: Date(timeIntervalSince1970: 1_234_567_890))),
                .mood(.mock(id: 2, date: Date(timeIntervalSince1970: 1_234_567_890)))
              ]
            )
            continuation.finish()
          }
        }
        $0.formatters.formatDate = { context in
          switch context {
            case .entryList:
              return { _ in "3:00 pm" }
            default:
              return { _ in
                return ""
              }
          }
        }
      }
    )
    
    await store.send(.onAppear)
    
    await store.receive(\.result) { state in
      state.entries = [
        .mood(.mock(id: 1, date: Date(timeIntervalSince1970: 1_234_567_890))),
        .mood(.mock(id: 2, date: Date(timeIntervalSince1970: 1_234_567_890)))
      ]
      state.shouldLoadDataOnAppear = false
    }
  }
  
  
}
