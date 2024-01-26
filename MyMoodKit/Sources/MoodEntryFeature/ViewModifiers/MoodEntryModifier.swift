//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-19.
//

import SwiftUI

struct MoodEntryModifier<PrimaryContent: View, TrailingContent: View>: ViewModifier {
  
  let backgroundColor: Color
  let currentDate: Date
  let displayedDate: String
  let shouldHideActionContent: () -> Bool
  let primaryAction: () -> PrimaryContent
  let trailingAction: () -> TrailingContent?
  
  init(
    backgroundColor: Color,
    currentDate: Date,
    date: Binding<Date>,
    displayedDate: String,
    @ViewBuilder primaryAction: @escaping () -> PrimaryContent,
    @ViewBuilder trailingAction: @escaping () -> TrailingContent,
    shouldHideActionContent: @escaping () -> Bool
  ) {
    self.backgroundColor = backgroundColor
    self.currentDate = currentDate
    self._date = date
    self.displayedDate = displayedDate
    self.primaryAction = primaryAction
    self.trailingAction = trailingAction
    self.shouldHideActionContent = shouldHideActionContent
  }
  
  @Binding private var date: Date
  @State private var showDatePicker: Bool = false
  
  func body(content: Content) -> some View {
    GeometryReader {
      let size = $0.size
      ZStack(alignment: .top) {
        backgroundColor.ignoresSafeArea()
        
        ZStack {
          
          HStack {
            Spacer()
            HStack(spacing: 0) {
              if self.showDatePicker {
                Button(
                  action: {
                    withAnimation(.snappy) {
                      self.showDatePicker = false
                    }
                  },
                  label: {
                    Image(systemName: "checkmark")
                      .font(.title3.bold())
                      .padding(.horizontal)
                  })
                .frame(width: 44, height: 44)
                .transition(.opacity.combined(with: .offset(x: 20)))
              } else {
                if let trailingContent = trailingAction() {
                  trailingContent
                    .frame(width: 44, height: 44)
                    .transition(.opacity.combined(with: .offset(x: -20)))
                }
              }
            }
          }
          .zIndex(100)
          .frame(maxWidth: .infinity)
          .overlay {
            if !self.showDatePicker {
              Button(
                action: {
                  withAnimation(.snappy) {
                    self.showDatePicker = true
                  }
                },
                label: {
                  HStack(spacing: 4) {
                    Image(systemName: "calendar")
                      .font(.title3.bold())
                    Text(self.displayedDate)
                      .fontWeight(.bold)
                      .lineLimit(1)
                  }
                })
              .scaledButton(scaleFactor: 0.9)
              .frame(height: 44)
              .frame(maxWidth: .infinity)
              .padding(.horizontal, 54)
              .transition(.opacity.combined(with: .move(edge: .top)))
              
            }
          }
        }
        .padding(.horizontal, 8)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .tint(.black)
        .background(backgroundColor)
        .zIndex(100)
        .opacity(shouldHideActionContent() ? 0 : 1)
        .offset(y: shouldHideActionContent() ? -200 : 0)        
        
          //Calendar view
        if self.showDatePicker {
          Group {
            backgroundColor
              .frame(height: 380)
              .frame(maxWidth: .infinity)
              .transition(.move(edge: .top))
              .zIndex(15)
            
            DatePicker(
              "Entry Date",
              selection: self.$date,
              in: ...currentDate,
              displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .frame(width: size.width * 0.8, height: 360)
            .zIndex(20)
            .frame(maxWidth: .infinity)
            .transition(.move(edge: .top).combined(with: .opacity))
            .tint(.black)
            
            VStack {
              Color.black.opacity(0.6)
                .ignoresSafeArea(edges: .bottom)
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                .onTapGesture {}
            }
            .zIndex(5)
          }
          .padding(.top, 58)
          .zIndex(20)
        }
        
        VStack(spacing: 10) {
          content
          
          primaryAction()
            .frame(maxWidth: .infinity)
            .padding()
            .opacity(shouldHideActionContent() ? 0 : 1)
            .offset(y: shouldHideActionContent() ? 100 : 0)
        }
        .padding(.top, 74)
        .zIndex(1.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
  }
}

extension View {
  @ViewBuilder
  func moodEntry<P: View, T: View>(
    backgroundColor: Color,
    currentDate: Date,
    date: Binding<Date>,
    displayedDate: String,
    @ViewBuilder primaryAction: @escaping () -> P,
    @ViewBuilder trailingAction: @escaping () -> T,
    shouldHideActionContent: @escaping () -> Bool = { false }
  ) -> some View {
    self.modifier(
      MoodEntryModifier(
        backgroundColor: backgroundColor,
        currentDate: currentDate,
        date: date,
        displayedDate: displayedDate,
        primaryAction: primaryAction,
        trailingAction: trailingAction,
        shouldHideActionContent: shouldHideActionContent
      )
    )
  }
}
