//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-08.
//

import SwiftUI
import Models

public struct WeatherPicker: View {
   
    @Binding var value: WeatherEntry?
    @Namespace var animation
    
    public init(value: Binding<WeatherEntry?>) {
        self._value = value
    }
    
    public var body: some View {
        
        HStack {
            ForEach(WeatherEntry.allCases, id: \.id) { entry in
                WeatherEntryView(
                    entry: entry,
                    selectedEntry: $value,
                    foregroundColor: self.value != nil ? .black : .black.opacity(0.6),
                    animation: animation
                )
            }
        }
        .animation(.snappy, value: value)
    }
}

struct WeatherEntryView: View {

    var entry: WeatherEntry
    @Binding var selectedEntry: WeatherEntry?
    var foregroundColor: Color
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack {
            Image(systemName: selectedEntry == entry ? entry.selectedIcon : entry.unselectedIcon)
                .font(.title3.bold())
                .foregroundStyle(selectedEntry == entry ? .white : foregroundColor)
                .frame(width: 40, height: 40)
                .background {
                    if selectedEntry == entry {
                        RoundedRectangle(cornerRadius: 10)
                            .matchedGeometryEffect(id: "selectedEntry", in: animation)
                    }
                }

            Text(entry.rawValue)
                .font(.caption.bold())
                .foregroundStyle(foregroundColor)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            self.selectedEntry = entry
        }
    }
}

#Preview {
    return WeatherPicker(value: .constant(.sunny))
}
