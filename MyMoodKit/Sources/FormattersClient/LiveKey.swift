//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import Dependencies
import Foundation

extension FormattersClient {
  public static var liveValue: FormattersClient = .init(
    formatDate: { date, context in
      switch context {
        case .datePicker:
          return date.formatted(date: .abbreviated, time: .shortened)
        case .entryList:
          return date.formatted(date: .abbreviated, time: .omitted)
        case .monthSelector:
          return date.formatted(
            Date.FormatStyle()
              .month(.wide)
              .year(.defaultDigits)
          )
      }
    }
  )
}
