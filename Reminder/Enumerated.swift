//
//  Enumerated.swift
//  Reminder
//
//  Created by Sahn Cha on 17/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

struct Enumerated {
    
    enum TransitionWorkType {
        case none, reminderAdded, reminderModified
    }
    
    enum Repeat: Int {
        case norepeat = 0, day, week, /*biweek,*/ month, year
        
        var title: String? {
            switch self {
            case .norepeat: return "do not repeat"
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            }
        }
        
        var cellTitle: String? {
            switch self {
            case .norepeat: return "Do not repeat"
            case .day: return "Every day"
            case .week: return "Every week"
            case .month: return "Every month"
            case .year: return "Every year"
            }
        }
    }
}
