//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-10.
//

import Foundation
import SwiftUI

extension String {
    public static func placeholder(length: Int) -> String {
        String(Array(repeating: "X", count: length))
    }
}

extension View {
    @ViewBuilder
    public func redacted(if condition: @autoclosure () -> Bool) -> some View {
        redacted(reason: condition() ? .placeholder : [])
    }
}
