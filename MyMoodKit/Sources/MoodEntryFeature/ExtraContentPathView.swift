//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-05.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Models

struct ExtraContentPathView: View {
    
    let store: StoreOf<MoodEntryFeature>
    let onShowObservations: (Bool) -> Void
        
    @Namespace var namespace
    @State private var showObservations = false
        
    struct ViewState: Equatable {
        @BindingViewState var observations: String
        
        init(bindingViewStore: BindingViewStore<MoodEntryFeature.State>) {
            self._observations = bindingViewStore.$moodEntry.observations
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            ZStack(alignment: .top) {
                if !showObservations {
                    VStack {
                        Section {
                            WeatherPathView(store: self.store)
                        }
                        .padding(.top, 40)
                        .padding(.horizontal)
                        
                        Section {
                            VStack {
                                HStack {
                                    Text("Notes and thoughts")
                                        .matchedGeometryEffect(id: "title", in: namespace)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                
                                Text(viewStore.observations.isEmpty ? "Tap to add extra notes and thoughts" : viewStore.observations.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(4)
                                    .foregroundStyle(viewStore.observations.isEmpty ? .black.opacity(0.3) : .black)
                                    .padding()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 2.0)
                                            .matchedGeometryEffect(id: "border", in: namespace)
                                    }
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        self.onShowObservations(true)
                                        withAnimation(.snappy) {
                                            self.showObservations = true
                                        }
                                    }
                            }
                        }
                        .padding(.top, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .transition(.opacity)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                    
                } else {
                    ObservationsView(
                        text: viewStore.$observations,
                        namespace: namespace
                    ) {
                        self.onShowObservations(false)
                        withAnimation(.snappy) {
                            self.showObservations = false
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        }
    }
}

struct ObservationsView: View {
    
    @Binding var text: String
    
    @FocusState var isTextFieldFocus: Bool
    
    @State private var isAppearing = false
    
    var namespace: Namespace.ID
    
    var onClose: () -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .bottom) {
                    HStack {
                        Text("Notes and thoughts")
                            .matchedGeometryEffect(id: "title", in: namespace)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal])
                    
                    HStack {
                        Button(
                            action: {
                                self.isTextFieldFocus = false
                                self.onClose()
                            },
                            label: {
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .foregroundStyle(.black)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 2.0)
                                    )
                                    .padding(.horizontal)
                                    .opacity(isAppearing ? 1 : 0)
                                    .offset(x: isAppearing ? 0 : 50)
                                
                            }
                        )
                        .scaledButton()
                        .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                VStack() {
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .padding(20)
                        .foregroundStyle(.black)
                        .tint(.black)
                        .frame(height: 400, alignment: .top)
                        .frame(maxWidth: .infinity)
                        .focused(self.$isTextFieldFocus)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 2.0)
                                .matchedGeometryEffect(id: "border", in: namespace)
                        }
                        .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            withAnimation(.snappy) {
                self.isTextFieldFocus = true
                isAppearing = true
            }
        }
        .onDisappear {
            withAnimation(.snappy) {
                self.isTextFieldFocus = false
            }
        }
    }
}

#Preview("Weather when location not determined") {
    ExtraContentPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockNotDetermined
                dependecyValues.weatherClient = .failure(delay: 1.0)
            }
        ),
        onShowObservations: { _ in }
    )
}

#Preview("Sunny Weather when location authorized") {
    ExtraContentPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .mock(.sunny, delay: 1.0)
            }
        ),
        onShowObservations: { _ in }
    )
}

#Preview("Error when location authorized") {
    ExtraContentPathView(
        store: Store(
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            ),
            reducer : {
                MoodEntryFeature()
            },
            withDependencies: { dependecyValues in
                dependecyValues.locationClient = .mockAuthorizedWhenInUse
                dependecyValues.weatherClient = .failure(delay: 1.0)
            }
        ),
        onShowObservations: { _ in }
    )
}
