//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import ComposableArchitecture

extension DependencyValues {
    public var formatters: FormattersClient {
        get {self[FormattersClient.self]}
        set { self[FormattersClient.self] = newValue }
    }
}

extension FormattersClient: DependencyKey {}
