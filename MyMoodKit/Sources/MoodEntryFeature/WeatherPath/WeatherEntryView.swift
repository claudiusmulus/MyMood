//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-10.
//

import SwiftUI
import Models

struct WeatherEntryView: View {
    let message: String
    let iconName: String
    let redactedCondition: () -> Bool
    
    init(
        message: String,
        iconName: String,
        redactedCondition: @autoclosure @escaping () -> Bool
    ) {
        self.message = message
        self.iconName = iconName
        self.redactedCondition = redactedCondition
    }
    
    var body: some View {
        HStack {
            Image(systemName: self.iconName)
                .font(.title)
                .foregroundStyle(self.redactedCondition() ? .black : .white)
                .redacted(if: self.redactedCondition())
                .padding()
                .background {
                    if !self.redactedCondition() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.black)
                    }
                }
            
            Text(self.message)
                .font(.title)
                .redacted(if: self.redactedCondition())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .roundedBorder(borderColor: .black)
    }
}


#Preview {
    WeatherEntryView(message: "Sunny", iconName: WeatherEntry.cloudy.selectedIcon, redactedCondition: false)
        .padding(.horizontal)
}
