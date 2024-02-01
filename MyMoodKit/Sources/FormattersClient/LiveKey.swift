//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import Dependencies
import Foundation

extension FormattersClient {
  public static var liveValue: FormattersClient = .init { context in
    switch context {
      case .datePicker:
        return { date in
          date.formatted(date: .abbreviated, time: .shortened)
        }
      case .entryList:
        return { date in
          date.formatted(.dateTime.day().weekday(.wide).month())
        }
      case .monthSelector:
        return { date in
          date.formatted(.dateTime.month(.wide).year(.defaultDigits))
        }
    }
  }
}
