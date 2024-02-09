//
//  ActivityPathFeatureTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import XCTest
import ComposableArchitecture
@testable import MoodEntryFeature
import Models
import SwiftUI

@MainActor
final class ActivityPathFeatureTests: XCTestCase {

  func testSelectActivityFlowWhenNoActivitiesSelected() async {
    let store = TestStoreOf<ActivityPathFeature>(
      initialState: ActivityPathFeature.State(
        availableActivities: Activity.allCases,
        selectedActivities: []
      ),
      reducer: {
        ActivityPathFeature()
      }
    )
    
    // Select an activity
    await store.send(.selectActivity(.family)) {
      $0.selectedActivities = [.family]
    }
    
    await store.receive(.delegate(.updateActivities([.family])))
    
    // Select another activity
    await store.send(.selectActivity(.work)) {
      $0.selectedActivities = [.family, .work]
    }
    
    await store.receive(.delegate(.updateActivities([.family, .work])))
    
    // Select same activity again
    await store.send(.selectActivity(.work))
    
    // Deselect one previously selected activity
    await store.send(.deselectActivity(Activity.family.id)) {
      $0.selectedActivities = [.work]
    }
    
    await store.receive(.delegate(.updateActivities([.work])))
  }
  
  func testSelectActivityFlowWhenPreviousActivitiesSelected() async {
    let store = TestStoreOf<ActivityPathFeature>(
      initialState: ActivityPathFeature.State(
        availableActivities: Activity.allCases,
        selectedActivities: [.exercise, .friends]
      ),
      reducer: {
        ActivityPathFeature()
      }
    )
    
    // Select an activity
    await store.send(.selectActivity(.family)) {
      $0.selectedActivities = [.exercise, .friends, .family]
    }
    
    await store.receive(.delegate(.updateActivities([.exercise, .friends, .family])))
    
    // Select another activity
    await store.send(.selectActivity(.work)) {
      $0.selectedActivities = [.exercise, .friends, .family, .work]
    }
    
    await store.receive(.delegate(.updateActivities([.exercise, .friends, .family, .work])))
    
    // Select same activity again
    await store.send(.selectActivity(.work))
    
    // Deselect one previously selected activity
    await store.send(.deselectActivity(Activity.family.id)) {
      $0.selectedActivities = [.exercise, .friends, .work]
    }
    
    await store.receive(.delegate(.updateActivities([.exercise, .friends, .work])))
  }

}
