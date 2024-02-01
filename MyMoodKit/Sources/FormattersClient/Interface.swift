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
  case entryList
  case monthSelector
}

public struct FormattersClient {
  public var formatDate: (_ context: DateContext) -> (_ date: Date) -> String
}
