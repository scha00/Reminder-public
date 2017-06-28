//
//  Notifications.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 6. 9..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    static let defaultInstance = Notifications()
    
    let calendar = Calendar.current
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]
    
    var notificationReceivedForeground: (() -> Void)? = nil
    
    private override init() {
        super.init()
        
        center.delegate = self
    }
    
    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func checkAuthorizationStatus(respond block: ((Bool) -> Void)?) {
        center.getNotificationSettings { [unowned self] settings in
            
            switch settings.authorizationStatus {
            case .authorized:
                block?(true)
            case .denied:
                block?(false)
            case .notDetermined:
                self.requestAuthorization(respond: block)
            }
        }
    }
    
    func requestAuthorization(respond block: ((Bool) -> Void)?) {
        center.requestAuthorization(options: options) { (granted, error) in /*block?(granted)*/ }
    }
    
    func sendNotification(identifier: String, title: String, body: String, repeatType: Enumerated.Repeat, day: Any?, time: Date, endOfMonth: Bool, completion: ((Bool) -> Void)?) {// onError: (() -> Void)?) {
        checkAuthorizationStatus { [unowned self] granted in
            
            if granted {
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default()
                
                let timeComps = self.calendar.dateComponents([.hour, .minute], from: time)
                
                var trigger: UNCalendarNotificationTrigger? = nil
                
                if repeatType == .norepeat {
                    if let date = day as! Date? {
                        let dateComps = self.calendar.dateComponents([.year, .month, .weekday, .day], from: date)
                        let target = DateComponents(year: dateComps.year, month: dateComps.month, day: dateComps.day, hour: timeComps.hour, minute: timeComps.minute)
                        trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: false)
                    }
                }
                
                else if repeatType == .day {
                    let target = DateComponents(hour: timeComps.hour, minute: timeComps.minute)
                    trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: true)
                }
                
                else if repeatType == .week {
                    if let weekday = day as! Int16? {
                        let target = DateComponents(hour: timeComps.hour, minute: timeComps.minute, weekday: Int(weekday) + 1)
                        trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: true)
                    }
                }
                
                else if repeatType == .month {
                    if endOfMonth {
                        let target = DateComponents(day: 1, hour: timeComps.hour! - 24, minute: timeComps.minute)
                        trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: true)
                    }
                    
                    else if let monthDay = day as! Int16? {
                        let target = DateComponents(day: Int(monthDay), hour: timeComps.hour, minute: timeComps.minute)
                        trigger = UNCalendarNotificationTrigger(dateMatching: target, repeats: true)
                    }
                }
                
                // Send notification request
                Logger.MSG("\(identifier): \(repeatType)")
                if let trigger = trigger {
                    Logger.MSG("next trigger: \(String(describing: trigger.nextTriggerDate()))")
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    self.center.add(request, withCompletionHandler: { (error) in
                        if let error = error {
                            Logger.MSG("LOCAL NOTIFICATION ERROR: \(error.localizedDescription)")
                            //onError?()
                            completion?(false)
                        } else {
                            Logger.MSG("LOCAL NOTIFICATION SUCCESS")
                            completion?(true)
                        }
                    })
                }
                
            } else {
                completion?(false)
            }
            
        }
    }
    
    func requestNotification(body: String, repeatType: Enumerated.Repeat, days: [(identifier: String, day: Any?, endOfMonth: Bool)], times: [(identifier: String, time: Date)], completion: ((Bool) -> Void)?) {
        
        for (index, time) in times.enumerated() {
            
            if repeatType == .day {
                let title = "Daily (\(index + 1) of \(times.count))"
                sendNotification(identifier: time.identifier.hash.description, title: title, body: body, repeatType: .day, day: nil, time: time.time, endOfMonth: false, completion: completion)//, onError: onError)
                continue
            }
            
            for day in days {
                var title = ""
                
                if repeatType == .norepeat {
                    title += "\(index + 1) of \(times.count)"
                }
                    
                else {
                    if repeatType == .week { title = "Weekly " }
                    else { title = "Monthly " }
                    
                    title += "(\(index + 1) of \(times.count))"
                }
                    
                let idString = "\(day.identifier)\(time.identifier)".hash.description
                sendNotification(identifier: idString, title: title, body: body, repeatType: repeatType, day: day.day, time: time.time, endOfMonth: day.endOfMonth, completion: completion)
            }
        }
        
    }
    
    func removeNotification(identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.notificationReceivedForeground?()
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
}
