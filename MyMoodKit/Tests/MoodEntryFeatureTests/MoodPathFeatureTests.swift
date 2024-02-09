//
//  MoodPathFeatureTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import XCTest
import ComposableArchitecture
@testable import MoodEntryFeature
import SwiftUI

@MainActor
final class MoodPathFeatureTests: XCTestCase {

  func testChangeMoodSliderToAwesome() async {
    let store = TestStoreOf<MoodPathFeature>(
      initialState: MoodPathFeature.State(
        moodScale: 0.5,
        mood: .okay
      ),
      reducer: {
        MoodPathFeature()
      }
    ) {
      $0.colorGenerator.generatedColor = { _ in
        Color.Resolved(red: 1, green: 1, blue: 1)
      }
    }
    
    await store.send(.binding(.set(\.$moodScale, 0.81))) { state in
      state.mood = .awesome
      state.moodScale = 0.81
    }
    
    await store.receive(
      .delegate(
        .update(
          color: Color.Resolved(red: 1, green: 1, blue: 1),
          mood: .awesome,
          scale: 0.81
        )
      )
    )

  }
  
  func testChangeMoodSliderToGood() async {
    let store = TestStoreOf<MoodPathFeature>(
      initialState: MoodPathFeature.State(
        moodScale: 0.5,
        mood: .okay
      ),
      reducer: {
        MoodPathFeature()
      }
    ) {
      $0.colorGenerator.generatedColor = { _ in
        Color.Resolved(red: 1, green: 1, blue: 1)
      }
    }
    
    await store.send(.binding(.set(\.$moodScale, 0.7))) { state in
      state.mood = .good
      state.moodScale = 0.7
    }
    
    await store.receive(
      .delegate(
        .update(
          color: Color.Resolved(red: 1, green: 1, blue: 1),
          mood: .good,
          scale: 0.7
        )
      )
    )
    
  }
  
  func testChangeMoodSliderToOkay() async {
    let store = TestStoreOf<MoodPathFeature>(
      initialState: MoodPathFeature.State(
        moodScale: 0.5,
        mood: .okay
      ),
      reducer: {
        MoodPathFeature()
      }
    ) {
      $0.colorGenerator.generatedColor = { _ in
        Color.Resolved(red: 1, green: 1, blue: 1)
      }
    }
    
    await store.send(.binding(.set(\.$moodScale, 0.4))) { state in
      state.mood = .okay
      state.moodScale = 0.4
    }
    
    await store.receive(
      .delegate(
        .update(
          color: Color.Resolved(red: 1, green: 1, blue: 1),
          mood: .okay,
          scale: 0.4
        )
      )
    )
    
  }
  
  func testChangeMoodSliderToBad() async {
    let store = TestStoreOf<MoodPathFeature>(
      initialState: MoodPathFeature.State(
        moodScale: 0.5,
        mood: .okay
      ),
      reducer: {
        MoodPathFeature()
      }
    ) {
      $0.colorGenerator.generatedColor = { _ in
        Color.Resolved(red: 1, green: 1, blue: 1)
      }
    }
    
    await store.send(.binding(.set(\.$moodScale, 0.25))) { state in
      state.mood = .bad
      state.moodScale = 0.25
    }
    
    await store.receive(
      .delegate(
        .update(
          color: Color.Resolved(red: 1, green: 1, blue: 1),
          mood: .bad,
          scale: 0.25
        )
      )
    )
    
  }
  
  func testChangeMoodSliderToTerrible() async {
    let store = TestStoreOf<MoodPathFeature>(
      initialState: MoodPathFeature.State(
        moodScale: 0.5,
        mood: .okay
      ),
      reducer: {
        MoodPathFeature()
      }
    ) {
      $0.colorGenerator.generatedColor = { _ in
        Color.Resolved(red: 1, green: 1, blue: 1)
      }
    }
    
    await store.send(.binding(.set(\.$moodScale, 0.1))) { state in
      state.mood = .terrible
      state.moodScale = 0.1
    }
    
    await store.receive(
      .delegate(
        .update(
          color: Color.Resolved(red: 1, green: 1, blue: 1),
          mood: .terrible,
          scale: 0.1
        )
      )
    )
    
  }

}
