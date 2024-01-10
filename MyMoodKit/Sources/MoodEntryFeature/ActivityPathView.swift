//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-04.
//

import SwiftUI
import Models
import ComposableArchitecture

struct ActivityPathView: View {
    
    let store: StoreOf<MoodEntryFeature>
    
    struct ViewState: Equatable {
        var backgroundColor: Color
        var activities: IdentifiedArrayOf<Activity>
        var availableActivities: [Activity]
        
        init(state: MoodEntryFeature.State) {
            self.backgroundColor = state.backgroundColor
            self.activities = state.moodEntry.activities
            self.availableActivities = state.availableActivities
        }
    }
    
    var body: some View {
        WithViewStore(self.store, observe: ViewState.init) { viewStore in
            VStack {
                Text("What have you been up to?")
                    .font(.title)
                    .foregroundStyle(viewStore.backgroundColor.adaptedTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .padding(.bottom, 10)
                
                let rows = [GridItem(.adaptive(minimum: 90, maximum: 90), spacing: 15)]

                ScrollView(.horizontal) {
                    
                    LazyHGrid(rows: rows, spacing: 10, content: {
                        ForEach(viewStore.availableActivities, id: \.id) { activity in
                            ActivityView(
                                activity: activity,
                                borderColor: viewStore.activities.isEmpty ? viewStore.backgroundColor.adaptedTextColor.opacity(0.6) : viewStore.backgroundColor.adaptedTextColor,
                                isSelected: viewStore.activities.contains(activity),
                                size: CGSize(width: 90, height: 90)
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
                        
                    })
                    .safeAreaPadding(.horizontal, 30)
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 330)
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
            initialState: MoodEntryFeature.State(
                moodEntry: .mockMeh()
            )
        ) {
            MoodEntryFeature()
        }
    )
}
