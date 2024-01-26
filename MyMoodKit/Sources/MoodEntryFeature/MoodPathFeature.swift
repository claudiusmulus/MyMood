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
                    let resolvedColor = colorGenerator.generatedColor(amount: Float(newValue))
                    
                    if let newMood = mood(scale: newValue) {
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
    
    private func mood(scale: Double) -> Mood? {
        guard scale >= 0, scale <= 1 else {
            return nil
        }
        switch scale {
        case 0..<0.20:
            return .terrible
        case 0.20..<0.40:
            return .bad
        case 0.40..<0.60:
            return .okay
        case 0.60..<0.80:
            return .good
        case 0.80...1:
            return .awesome
        default:
            return nil
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
