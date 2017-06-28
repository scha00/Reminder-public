//
//  Date+Reminder.swift
//  Reminder
//
//  Created by Sahn Cha on 02/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let startOfDay = self.startOfDay
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func date(byAdding component: Calendar.Component, value: Int) -> Date {
        if let date = Calendar.current.date(byAdding: component, value: value, to: self) {
            return date
        }
        return self
    }
    
    func compare(date: Date, toGranularity g: Calendar.Component) -> ComparisonResult {
        return Calendar.current.compare(self, to: date, toGranularity: g)
    }
    
}
