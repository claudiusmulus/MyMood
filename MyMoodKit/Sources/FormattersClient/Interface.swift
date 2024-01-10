//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import Foundation
import ComposableArchitecture

public enum DateContext {
    case datePicker
}

@DependencyClient
public struct FormattersClient {
    public var formatDate: (_ date: Date, _ context: DateContext) -> String = { _, _ in "" }
}
