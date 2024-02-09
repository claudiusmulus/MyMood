//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2024-02-08.
//

import Foundation

extension Double {
  public func mood() -> Mood? {
    guard self >= 0, self <= 1 else {
      return nil
    }
    switch self {
      case 0..<0.20:
        return .terrible
      case 0.20..<0.40:
        return .bad
      case 0.40..<0.60:
        return .okay
      case 0.60..<0.80:
        return .good
      case 0.80...1:
        return .awesome
      default:
        return nil
    }
  }
}
