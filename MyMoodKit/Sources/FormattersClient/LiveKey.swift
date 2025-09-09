//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-01-03.
//

import Dependencies
import Foundation

extension FormattersClient {
  
  static let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM/yyyy"
    return formatter
  }()
  
  public static var liveValue: FormattersClient = {
    @Dependency(\.calendar) var calendar
    
    let client = FormattersClient(
      formatDate: { context in
        switch context {
          case .datePicker:
            return { date in
              date.formatted(date: .abbreviated, time: .shortened)
            }
          case .entryList(.item):
            return { date in
              date.formatted(date: .omitted, time: .shortened)
            }
          case .entryList(.weeklySection):
            return { date in
              if calendar.isDateInToday(date) {
                // TODO. Review copy
                return "Today"
              } else  if calendar.isDateInYesterday(date) {
                return "Yesterday"
              } else {
                return date.formatted(.dateTime.day().weekday(.wide))
              }
            }
            
          case .monthSelector(.actionButton):
            return { date in
              date.formatted(.dateTime.month(.wide).year(.defaultDigits))
            }
          case .monthSelector(.yearTitle):
            return { date in
              date.formatted(.dateTime.year(.defaultDigits))
            }
          case .monthSelector(.monthTitle):
            return { date in
              date.formatted(.dateTime.month(.abbreviated))
            }
        }
      },
      generateDate: { context in
        switch context {
          case .monthSelector:
            return { string in
              Self.monthYearFormatter.date(from: string)
            }
        }
      }
    )
    
    return client
  }()
}
