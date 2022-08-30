//
//  Date+Formatter.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/30.
//

import Foundation

fileprivate let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_kr")
    return f
}()

extension Date {
    var dateString: String {
        dateFormatter.dateFormat = "M월 d일"
        return dateFormatter.string(from: self)
    }
    
    var timeString: String {
        dateFormatter.dateFormat = "HH:00"
        return dateFormatter.string(from: self)
    }
}
