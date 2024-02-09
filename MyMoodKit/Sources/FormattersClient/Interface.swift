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
  case monthSelector(MonthSelector)
  
  public enum MonthSelector {
    case actionButton
    case yearTitle
    case monthTitle
  }
}

public enum StringContext {
  case monthSelector
}

public struct FormattersClient {
  public var formatDate: (_ context: DateContext) -> (_ date: Date) -> String
  public var generateDate: (_ context: StringContext) -> (_ string: String) -> Date?
}
