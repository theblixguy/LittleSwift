//
//  Date.swift
//  LittleSwift
//
//  Created by Suyash Srijan on 20/10/2018.
//  Copyright © 2018 Suyash Srijan. All rights reserved.
//

import Foundation

extension TimeZone {
  static let gmt = TimeZone(secondsFromGMT: 0)!
}
extension Formatter {
  static let date = DateFormatter()
}

extension Date {
  func localizedDescription(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium, in timeZone: TimeZone = .current, locale: Locale = .current) -> String {
    Formatter.date.locale = locale
    Formatter.date.timeZone = timeZone
    Formatter.date.dateStyle = dateStyle
    Formatter.date.timeStyle = timeStyle
    return Formatter.date.string(from: self)
  }
  
  var localizedDescription: String {
    return localizedDescription()
  }
}

extension Date {
  var fullDate: String { return localizedDescription(dateStyle: .full)  }
  var shortDate: String { return localizedDescription(dateStyle: .short)  }
  var fullTime: String { return localizedDescription(timeStyle: .full)  }
  var shortTime: String { return localizedDescription(timeStyle: .short)   }
  var fullDateTime: String { return localizedDescription(dateStyle: .full, timeStyle: .full)  }
  var shortDateTime: String { return localizedDescription(dateStyle: .short, timeStyle: .short)  }
}
