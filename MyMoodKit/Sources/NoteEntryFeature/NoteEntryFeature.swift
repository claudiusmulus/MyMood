  //
  //  File.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-22.
  //

import SwiftUI
import ComposableArchitecture
import UIComponents

@Reducer
public struct NoteEntryFeature: Reducer {
  
  public init() {}
  
  public struct State: Equatable {
    @BindingState var notes: String
    @BindingState var isAppearing = false
    
    public init(notes: String) {
      self.notes = notes
      self.isAppearing = isAppearing
    }
  }
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case closeButtonTapped
    case isAppearing
    case saveButtonTapped
    
    public enum Delegate: Equatable {
      case updateNotes(String)
      case closeNotes
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.continuousClock) var clock
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
        case .binding:
          return .none
        case .closeButtonTapped:
          state.isAppearing = false
          return .run { send in
            try await self.clock.sleep(for: .seconds(0.1))
            await send(.delegate(.closeNotes), animation: .snappy)
          }
        case .delegate:
          return .none
        case .isAppearing:
          state.isAppearing = true
          return .none
        case .saveButtonTapped:
          state.isAppearing = false
          return .run { [notes = state.notes] send in
            try await self.clock.sleep(for: .seconds(0.1))
            await send(.delegate(.updateNotes(notes)), animation: .snappy)
          }
      }
    }
  }
}

public struct NotesView: View {
  
  let store: StoreOf<NoteEntryFeature>
  var namespace: Namespace.ID
  
  public init(
    store: StoreOf<NoteEntryFeature>,
    namespace: Namespace.ID
  ) {
    self.store = store
    self.namespace = namespace
  }
  
  struct ViewState: Equatable {
    @BindingViewState var notes: String
    @BindingViewState var isAppearing: Bool
    
    init(bindingViewStore: BindingViewStore<NoteEntryFeature.State>) {
      self._notes = bindingViewStore.$notes
      self._isAppearing = bindingViewStore.$isAppearing
    }
  }
  
  @FocusState var isTextFieldFocus: Bool
  @State private var showNavigationDivider = true

  
  public var body: some View {
    let _ = Self._printChanges()
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      VStack(spacing: 0) {
        HStack {
          Button(
            action: {
              self.isTextFieldFocus = false
              self.showNavigationDivider = false
              viewStore.send(.closeButtonTapped, animation: .snappy)
            }, label: {
              Text("Close")
                .padding(.horizontal)
            })
          .secondaryButton(borderColor: .black, borderWidth: 2.0)
          .opacity(viewStore.isAppearing ? 1 : 0)
          .offset(x: viewStore.isAppearing ? 0 : -150)

          Spacer()
          
          Button(
            action: {
              self.isTextFieldFocus = false
              self.showNavigationDivider = false
              viewStore.send(.saveButtonTapped, animation: .snappy)
            }, label: {
              Text("Save")
                .foregroundStyle(.white)
                .padding(.horizontal)
            })
          .primaryButton(backgroundStyle: .black)
          .opacity(viewStore.isAppearing ? 1 : 0)
          .offset(x: viewStore.isAppearing ? 0 : 150)
        }
        
        .frame(maxWidth: .infinity)
        .padding()
        .background(alignment: .bottom) {
          Rectangle()
            .fill(.black)
            .frame(height: 1)
            .shadow(color: .black.opacity(0.8), radius: 5, x: 0.0, y: 2.0)
            .opacity(self.showNavigationDivider ? 1 : 0)
        }
        .zIndex(10)
        
        ScrollView {
          VStack(spacing: 8) {
            HStack {
              Text("Notes and thoughts")
                .matchedGeometryEffect(id: "title", in: self.namespace)
              
              Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)
            
            VStack() {
              TextEditor(text: viewStore.$notes)
                .scrollContentBackground(.hidden)
                .padding(20)
                .foregroundStyle(.black)
                .tint(.black)
                .frame(height: 320, alignment: .top)
                .frame(maxWidth: .infinity)
                .focused(self.$isTextFieldFocus)
                .overlay {
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 2.0)
                    .matchedGeometryEffect(id: "border", in: self.namespace)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 100)
          }
          .scrollOffsetY {
            self.showNavigationDivider = $0 < 0
          }
        }
        .scrollBounceBehavior(.basedOnSize)
      }
      .task {
        viewStore.send(.isAppearing, animation: .snappy)
      }
      .bind(viewStore.$isAppearing, to: self.$isTextFieldFocus)
    }
  }
}

#Preview {
  @Namespace var namespace
  return NotesView(
    store: Store<NoteEntryFeature.State, NoteEntryFeature.Action>(
      initialState: NoteEntryFeature.State(notes: ""),
      reducer: {
        NoteEntryFeature()
      }),
    namespace: namespace
  )
}
