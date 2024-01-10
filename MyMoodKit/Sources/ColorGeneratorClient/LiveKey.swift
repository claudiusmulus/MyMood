//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-19.
//

import Dependencies
import SwiftUI

extension ColorGeneratorClient {
    public static func live(
        initialColorResolved: Color.Resolved,
        middleColorResolved: Color.Resolved,
        finalColorResolved: Color.Resolved,
        initialValue: Float = 0,
        finalValue: Float = 1
    ) -> Self {
    
        let colorGenerator = ColorGenerator(
            initialColorResolved: initialColorResolved,
            middleColorResolved: middleColorResolved,
            finalColorResolved: finalColorResolved,
            initialValue: initialValue,
            finalValue: finalValue
        )
        
        return Self { amount in
            colorGenerator.color(amount: amount)
        }
        
    }
}
