//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-10.
//

import SwiftUI

public struct DynamicInfoActionHStack: View {
    let message: String
    let actionTitle: String
    let actionBackgroundColor: Color
    let action: () -> Void
    let redactedCondition: () -> Bool
    
    public init(
        message: String,
        actionTitle: String,
        actionBackgroundColor: Color,
        action: @escaping () -> Void,
        redactedCondition: @autoclosure @escaping () -> Bool
    ) {
        self.message = message
        self.actionTitle = actionTitle
        self.actionBackgroundColor = actionBackgroundColor
        self.action = action
        self.redactedCondition = redactedCondition
    }
    
    public var body: some View {
        HStack() {
            Text(self.message)
                .redacted(if: self.redactedCondition())

            Spacer()
            
            Button(
                action: {
                    self.action()
            },
                label: {
                    Text(self.actionTitle)
                        .redacted(if: self.redactedCondition())
                        .opacity(self.redactedCondition() ? 0 : 1)
            })
            .foregroundStyle(.white)
            .disabled(self.redactedCondition())
            .redactedFillButton(if: self.redactedCondition(), backgroundColor: self.actionBackgroundColor)
            
        }
    }
}

#Preview("Message") {
    DynamicInfoActionHStack(
        message: "This is a text message",
        actionTitle: "Action title",
        actionBackgroundColor: .black,
        action: { },
        redactedCondition: false
    )
    .padding(.horizontal)
}

#Preview("Redacted") {
    DynamicInfoActionHStack(
        message: "This is a text message",
        actionTitle: "Action title",
        actionBackgroundColor: .black,
        action: { },
        redactedCondition: true
    )
    .padding(.horizontal)
}
