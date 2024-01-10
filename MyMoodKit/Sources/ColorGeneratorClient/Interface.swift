//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-12-19.
//
import SwiftUI
import DependenciesMacros

@DependencyClient
public struct ColorGeneratorClient {
    public var generatedColor: (_ amount: Float) -> Color.Resolved = { _ in .init(red: 1, green: 1, blue: 1) }
}



