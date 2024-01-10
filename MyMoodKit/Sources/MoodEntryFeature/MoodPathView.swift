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

struct MoodPathView: View {
    
    let store: StoreOf<MoodEntryFeature>
    
    struct ViewState: Equatable {
        var backgroundColor: Color
        @BindingViewState var moodScale: Double
        var moodTitle: String
        
        init(bindingViewStore: BindingViewStore<MoodEntryFeature.State>) {
            self.backgroundColor = bindingViewStore.backgroundColor
            self._moodScale = bindingViewStore.$moodEntry.moodScale
            self.moodTitle = bindingViewStore.moodEntry.mood.title
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                
                Text("Hey Alberto. How are you feeling now?")
                    .font(.title)
                    .foregroundStyle(viewStore.backgroundColor.adaptedTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                
                Face(
                    eyeSize: CGSize(width: 50, height: 50),
                    smileSize: CGSize(width: 150, height: 80),
                    offset: viewStore.moodScale
                )
                .frame(width: 150)
                
                Text(viewStore.moodTitle)
                    .padding(.horizontal)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    .font(.title2)
                    .animation(.smooth, value: viewStore.moodTitle)
                
                CustomSlider(value: viewStore.$moodScale, range: 0...1)
                    .padding(.horizontal)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    MoodPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            )
        ) {
            MoodEntryFeature()
        }
    )
}
