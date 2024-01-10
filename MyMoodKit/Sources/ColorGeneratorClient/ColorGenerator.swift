//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-19.
//

import Foundation
import SwiftUI

struct ColorGenerator {
    let initialColorResolved: Color.Resolved
    let middleColorResolved: Color.Resolved
    let finalColorResolved: Color.Resolved
    let initialValue: Float
    let finalValue: Float
    let middleValue: Float
    
    init(
        initialColorResolved: Color.Resolved,
        middleColorResolved: Color.Resolved,
        finalColorResolved: Color.Resolved,
        initialValue: Float,
        finalValue: Float
    ) {
        self.initialColorResolved = initialColorResolved
        self.middleColorResolved = middleColorResolved
        self.finalColorResolved = finalColorResolved
        self.initialValue = initialValue
        self.finalValue = finalValue
        self.middleValue = finalValue / 2
    }
    
    func color(amount: Float) -> Color.Resolved {
        Color.Resolved(
            red: self.colorComponent(amountChange: amount, colorComponentKeyPath: \.red),
            green: self.colorComponent(amountChange: amount, colorComponentKeyPath: \.green),
            blue: self.colorComponent(amountChange: amount, colorComponentKeyPath: \.blue)
        )
    }
    
    // MARK: - Private helpers
    /*
     Calculate the color component change use a linear equation (y = a + b*x)
     */
    private func colorComponentChange(
        initialColorCode: Float,
        finalColorCode: Float,
        initialValue: Float,
        finalValue: Float
    ) -> (_ amount: Float) -> Float {
        return { amount in
            
            let a = initialColorCode - (initialValue*(finalColorCode - initialColorCode)/(finalValue - initialValue))
            let b = (finalColorCode - initialColorCode) / (finalValue - initialValue)

            return a + b*amount
        }
    }
    
    private func colorComponent(
        amountChange: Float,
        colorComponentKeyPath: KeyPath<Color.Resolved, Float>
    ) -> Float {
        let initialColorCode = self.initialColorResolved[keyPath: colorComponentKeyPath]
        let middleColorCode = self.middleColorResolved[keyPath: colorComponentKeyPath]
        let finalColorCode = self.finalColorResolved[keyPath: colorComponentKeyPath]
        if amountChange <= self.middleValue {
            guard initialColorCode != middleColorCode else {
                return initialColorCode
            }
            return self.colorComponentChange(initialColorCode: initialColorCode, finalColorCode: middleColorCode, initialValue: initialValue, finalValue: middleValue)(amountChange)
        } else {
            guard middleColorCode != finalColorCode else {
                return finalColorCode
            }
            return self.colorComponentChange(initialColorCode: middleColorCode, finalColorCode: finalColorCode, initialValue: middleValue, finalValue: finalValue)(amountChange)
        }
    }
}
