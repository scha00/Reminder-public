//
//  ReminderTests.swift
//  ReminderTests
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import XCTest
import UserNotifications
@testable import Reminder

class ReminderTests: XCTestCase {
    
    let system: SNSystem = SNSystem.defaultInstance
    let calendar = Calendar.current
    
    var days: [Date] = []
    var times: [Date] = []
    var weekdays: [Int] = []
    var monthdays: [Int] = []
    
    var uniqueIds: [String?] = []
    
    override func setUp() {
        super.setUp()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("*** <<< request count: \(requests.count)")
            for request in requests {
                print("*** <<< request: \(request.identifier)")
            }
        }
        
        days = []
        times = []
        weekdays = []
        monthdays = []
        
        days.append(calendar.date(from: DateComponents(year: 2220, month: 5, day: 1, hour: 0, minute: 0))!)
//        days.append(calendar.date(from: DateComponents(year: 2220, month: 5, day: 15, hour: 0, minute: 0))!)
//        days.append(calendar.date(from: DateComponents(year: 2220, month: 6, day: 3, hour: 0, minute: 0))!)
        
        times.append(calendar.date(from: DateComponents(year: 2220, month: 1, day: 1, hour: 9, minute: 0))!)
//        times.append(calendar.date(from: DateComponents(year: 2220, month: 1, day: 1, hour: 14, minute: 20))!)
//        times.append(calendar.date(from: DateComponents(year: 2220, month: 1, day: 1, hour: 16, minute: 40))!)
        
        weekdays.append(2) // Monday
        weekdays.append(4) // Wednesday
        
        monthdays.append(8)
//        monthdays.append(20)
    }
    
    override func tearDown() {
        super.tearDown()
        
        days = []
        times = []
        weekdays = []
        monthdays = []
        
        print("*** tearing down")
        for uniqueId in uniqueIds {
            if let id = uniqueId {
                print("deleting: \(id)")
                system.deleteReminder(uniqueId: id)
            }
        }
        
        uniqueIds = []
        
        print("*** >>> sending remove notification request")
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("*** >>> request count: \(requests.count)")
            for request in requests {
                print("*** >>> request: \(request.identifier)")
            }
        }
    }
    
    func testCanInsertReminder() {
        print("*** test: inserting reminder")
        system.insertReminder(number: -100, title: "XCTest", color: SNThemeColor().data, repeatType: .norepeat, times: times, days: days, weekdays: [], monthdays: [])
        
        let uniqueId = system.reminderUniqueIdBy(number: -100)
        uniqueIds.append(uniqueId)
        print("insert: \(String(describing: uniqueId))")
        
        XCTAssertNotNil(uniqueId)
    }
    
    func testCanRegisterLocalNotification() {
        print("*** test: register local notification")
        let expectation = self.expectation(description: "Register Local Notification")
        
        system.insertReminder(number: -101, title: "XCTest", color: SNThemeColor().data, repeatType: .week, times: times, days: [], weekdays: weekdays, monthdays: [])
        let uniqueId = system.reminderUniqueIdBy(number: -101)
        uniqueIds.append(uniqueId)
        print("insert: \(String(describing: uniqueId))")
        
        if let id = uniqueId {
            let notificationIds = system.notificationIdsBy(uniqueId: id)
            var idDictionary = notificationIds.reduce([String: Bool](), { (aggregate, identifier) -> [String: Bool] in
                var new = aggregate
                new[identifier] = false
                return new
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                    for request in requests {
                        print("request: \(request.identifier)")
                        if let _ = idDictionary[request.identifier] {
                            idDictionary[request.identifier] = true
                        }
                    }
                    
                    if !idDictionary.contains(where: { $0.1 == false }) {
                        expectation.fulfill()
                    }
                    print(idDictionary)
                }
            })
        }
        
        self.wait(for: [expectation], timeout: 3)
    }
    
    func testCanCalculateNextNotificationDate() {
        system.insertReminder(number: -102, title: "XCTest", color: SNThemeColor().data, repeatType: .norepeat, times: times, days: days, weekdays: [], monthdays: [])
        let uniqueId = system.reminderUniqueIdBy(number: -102)
        uniqueIds.append(uniqueId)
        
        if let id = uniqueId {
            if let date = system.nextNotificationDateForReminder(uniqueId: id) {
                let targetDate = calendar.date(from: DateComponents(year: 2220, month: 5, day: 1, hour: 9, minute: 0))!
                XCTAssertEqual(date, targetDate)
            }
        }
    }
    
}
