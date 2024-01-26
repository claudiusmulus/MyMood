  //
  //  SwiftUIView.swift
  //
  //
  //  Created by Alberto Novo Garrido on 2024-01-04.
  //

import SwiftUI
import Models
import ComposableArchitecture

@Reducer
public struct ActivityPathFeature: Reducer {
  public struct State: Equatable {
    var availableActivities: [Activity]
    var selectedActivities: IdentifiedArrayOf<Activity>
  }
  
  public enum Action: Equatable {
    case selectActivity(Activity)
    case deselectActivity(Activity.Id)
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case updateActivities(IdentifiedArrayOf<Activity>)
    }
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .delegate:
          return .none
        case let .deselectActivity(id):
          state.selectedActivities.remove(id: id)
          
          return .run { [activities = state.selectedActivities] send in
            await send(.delegate(.updateActivities(activities)))
          }
        case let .selectActivity(activity):
          guard !state.selectedActivities.contains(activity) else {
            return .none
          }
          state.selectedActivities.append(activity)
          return .run { [activities = state.selectedActivities] send in
            await send(.delegate(.updateActivities(activities)))
          }
      }
    }
  }
}

struct ActivityPathView: View {
  
  let store: StoreOf<ActivityPathFeature>
  
  var body: some View {
    
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      let _ = Self._printChanges()
      VStack {
        Text("What have you been up to?")
          .font(.title)
          .foregroundStyle(.black)
          .multilineTextAlignment(.center)
          .padding(.top, 20)
          .padding(.bottom, 10)
        
        ScrollView(.vertical) {
          LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 80, maximum: 80))],
            spacing: 10,
            content: {
              ForEach(viewStore.availableActivities, id: \.id) { activity in
                ActivityView(
                  activity: activity,
                  borderColor: viewStore.selectedActivities.isEmpty ? .black.opacity(0.6) : .black,
                  isSelected: viewStore.selectedActivities.contains(activity),
                  size: CGSize(width: 80, height: 80)
                ) { activity, isSelected in
                  if isSelected {
                    viewStore.send(.selectActivity(activity))
                  } else {
                    viewStore.send(.deselectActivity(activity.id))
                  }
                }
                .scaledButton(scaleFactor: 0.85)
                .scrollTargetLayout()
              }
              
            }
          )
        }
        .padding(.horizontal, 10)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      
    }
    
  }
}

struct ActivityView: View {
  let activity: Activity
  let size: CGSize
  let borderColor: Color
  let onTap: (Activity, Bool) -> Void
  
  init(
    activity: Activity,
    borderColor: Color,
    isSelected: Bool,
    size: CGSize,
    onTap: @escaping (Activity, Bool) -> Void
  ) {
    self.activity = activity
    self.size = size
    self.borderColor = borderColor
    self.onTap = onTap
    self.isSelected = isSelected
  }
  
  @State private var isSelected: Bool
  
  var body: some View {
    Button(
      action: {
        let wasPreviousSelected = self.isSelected
        withAnimation {
          isSelected.toggle()
        }
        onTap(activity, !wasPreviousSelected)
      },
      label: {
        VStack {
          Image(systemName: isSelected ? activity.selectedIconName : activity.unselectedIconName)
            .font(.title3)
            .foregroundStyle(isSelected ? .white : borderColor)
            .frame(width: 40, height: 40)
            .background {
              if isSelected {
                RoundedRectangle(cornerRadius: 10).fill(.black)
              }
            }
          
          Text(activity.title)
            .font(.footnote)
            .foregroundStyle(borderColor)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
        .frame(width: size.width, height: size.height)
          //        .background(
          //            RoundedRectangle(cornerRadius: 20).stroke(isSelected ? borderColor : .clear, lineWidth: 2.0)
          //        )
        .fontWeight(.medium)
      }
    )
  }
}

#Preview {
  ActivityPathView(
    store: Store(
      initialState: ActivityPathFeature.State(
        availableActivities: Activity.allCases,
        selectedActivities: []
      )
    ) {
      ActivityPathFeature()
    }
  )
}
