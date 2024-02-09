//
//  SwiftUIView 2.swift
//
//
//  Created by Alberto Novo Garrido on 2023-12-22.
//

import SwiftUI
import ComposableArchitecture
import Models
import UIComponents

@Reducer
public struct MoodPathFeature: Reducer {
  
  public struct State: Equatable {
    @BindingState var moodScale: Double
    var mood: Mood
    
    public init(moodScale: Double, mood: Mood) {
      self.moodScale = moodScale
      self.mood = mood
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case update(color: Color.Resolved, mood: Mood?, scale: Double)
    }
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
      .onChange(of: \.moodScale) { oldValue, newValue in
        Reduce { state, _ in
          @Dependency(\.colorGenerator) var colorGenerator
          let resolvedColor = colorGenerator.generatedColor(Float(newValue))
          
          if let newMood = newValue.mood() {
            state.mood = newMood
            return .run { send in
              await send(.delegate(.update(color: resolvedColor, mood: newMood, scale: newValue)))
            }
          } else {
            return .run { send in
              await send(.delegate(.update(color: resolvedColor, mood: nil, scale: newValue)))
            }
          }
          
        }
      }
    
    Reduce { state, action in
      switch action {
        case .binding:
          return .none
        case .delegate:
          return .none
      }
    }
  }
}


struct MoodPathView: View {
  
  let store: StoreOf<MoodPathFeature>
  
  struct ViewState: Equatable {
    @BindingViewState var moodScale: Double
    var moodTitle: String
    
    init(bindingViewStore: BindingViewStore<MoodPathFeature.State>) {
      self._moodScale = bindingViewStore.$moodScale
      self.moodTitle = bindingViewStore.mood.title
    }
  }
  
  var body: some View {
    
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      let _ = Self._printChanges()
      ScrollView {
        VStack {
          
          Text("Hey Alberto. How are you feeling now?")
            .font(.title)
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .padding(.top, 20)
            .padding(.bottom, 30)
          
          Face(
            eyeSize: CGSize(width: 50, height: 50),
            offset: viewStore.moodScale,
            smileSize: CGSize(width: 150, height: 80)
          )
          .frame(width: 150)
          
          Text(viewStore.moodTitle)
            .padding(.horizontal)
            .padding(.top, 30)
            .padding(.bottom, 20)
            .font(.title2)
            .animation(.smooth, value: viewStore.moodTitle)
          
          CustomSlider(value: viewStore.$moodScale, range: 0...1)
            .padding(.horizontal)
          
        }
      }
      .scrollBounceBehavior(.basedOnSize)
    }
  }
}

#Preview {
  MoodPathView(
    store: Store(
      initialState: MoodPathFeature.State(
        moodScale: 0.5,
        mood: .okay
      )
    ) {
      MoodPathFeature()
    }
  )
}
