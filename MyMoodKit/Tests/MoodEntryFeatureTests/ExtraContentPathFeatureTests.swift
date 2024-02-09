//
//  ExtraContentPathFeatureTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import XCTest
import ComposableArchitecture
@testable import MoodEntryFeature
import WeatherClient
import Models
import SwiftUI

@MainActor
final class ExtraContentPathFeatureTests: XCTestCase {

  func testAppearWhenLocationNotDeterminedAndAuthorizedFetchWeatherSucceeded() async {
    
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    ) {
      $0.locationClient.authorizationStatus = { .notDetermined }
      $0.locationClient.requestUserLocation = {
        .init(latitude: 50.0, longitude: 50.0)
      }
      $0.weatherClient.weather = { _, _ in .sunny }
    }
    
    await store.send(.onAppear)
    
    await store.receive(\.weatherDisplay) {
      $0.weatherDisplay = .whenLocationNotDetermined
    }
    
    await store.send(.fetchCurrentWeatherButtonTapped)
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .loading
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .result(.sunny)
    }
    
    await store.receive(.delegate(.updateWeatherEntry(.sunny)))
    
  }
  
  func testAppearWhenLocationNotDeterminedAndAuthorizedFetchWeatherFailed() async {
    
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    ) {
      $0.locationClient.authorizationStatus = { .notDetermined }
      $0.locationClient.requestUserLocation = {
        .init(latitude: 50.0, longitude: 50.0)
      }
      $0.weatherClient.weather = { _, _ in throw WeatherClientError.weatherNotAvailable }
    }
    
    await store.send(.onAppear)
    
    await store.receive(\.weatherDisplay) {
      $0.weatherDisplay = .whenLocationNotDetermined
    }
    
    await store.send(.fetchCurrentWeatherButtonTapped)
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .loading
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .error(message: "Weather not available")
    }
    
  }
  
  func testAppearWhenLocationNotDeterminedAndDeniedLocation() async {
    
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    ) {
      $0.locationClient.authorizationStatus = { .notDetermined }
      $0.locationClient.requestUserLocation = {
        nil
      }
    }
    
    await store.send(.onAppear)
    
    await store.receive(\.weatherDisplay) {
      $0.weatherDisplay = .whenLocationNotDetermined
    }
    
    await store.send(.fetchCurrentWeatherButtonTapped)
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .loading
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus =  .error(message: "Location not available")
    }
    
  }
    
  func testAppearWhenLocationAuthorizedAndFetchWeatherSucceeded() async {
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    ) {
      $0.locationClient.authorizationStatus = { .authorizedWhenInUse }
      $0.locationClient.requestUserLocation = {
        .init(latitude: 50.0, longitude: 50.0)
      }
      $0.weatherClient.weather = { _, _ in .sunny }
    }
    
    await store.send(.onAppear)
    
    await store.receive(\.weatherDisplay) {
      $0.weatherDisplay = .whenLocationAuthorized
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .loading
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .result(.sunny)
    }
    
    await store.receive(.delegate(.updateWeatherEntry(.sunny)))
  }
  
  func testAppearWhenLocationAuthorizedAndFetchWeatherFailed() async {
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    ) {
      $0.locationClient.authorizationStatus = { .authorizedWhenInUse }
      $0.locationClient.requestUserLocation = {
        .init(latitude: 50.0, longitude: 50.0)
      }
      $0.weatherClient.weather = { _, _ in throw WeatherClientError.weatherNotAvailable }
    }
    
    await store.send(.onAppear)
    
    await store.receive(\.weatherDisplay) {
      $0.weatherDisplay = .whenLocationAuthorized
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .loading
    }
    
    await store.receive(\.weatherStatus) { state in
      state.weatherStatus = .error(message: "Weather not available")
    }
  }

  func testAppearWhenLocationDenied() async {
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    ) {
      $0.locationClient.authorizationStatus = { .denied }
    }
    
    await store.send(.onAppear)
    
    await store.receive(\.weatherDisplay) {
      $0.weatherDisplay = .whenLocationDenied
    }
  }
  
  func testClickShowNotes() async {
    let store = TestStoreOf<ExtraContentPathFeature>(
      initialState: ExtraContentPathFeature.State(notes: ""),
      reducer: {
        ExtraContentPathFeature()
      }
    )
    
    await store.send(.showNotesButtonTapped)
    
    await store.receive(.delegate(.displayNotes))
  }
}
