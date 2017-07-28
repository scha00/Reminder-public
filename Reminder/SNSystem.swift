//
//  SNSystem.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import StoreKit
import KeychainAccess
import IDZSwiftCommonCrypto
import Sphere

/// System parameters & environments for the application
final class SNSystem: NSObject {
    
    static let defaultInstance = SNSystem()
    
    private let keyCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()~_-?/[].,+="
    private let defaultTheme = Constants.Theme.Basic
    
    // Timestamp base date used for unique id generation
    private let baseDate = Calendar.current.date(from: DateComponents(year: 2017, month: 6, day: 1))!
    
    fileprivate var notificationCenter = NotificationCenter.default
    fileprivate var sphere: Sphere! = Sphere.defaultInstance
    fileprivate var localNotification = Notifications.defaultInstance
    
    fileprivate var productRequest: SKProductsRequest? = nil
    fileprivate var productRequestResponseBlock: (([SKProduct]?) -> Void)? = nil
    fileprivate var products: [SKProduct] = []
    
    // Local notification received in foreground
    var localNotificationReceivedForeground: (() -> Void)? = nil
    
    private override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
        localNotification.requestAuthorization(respond: nil)
        localNotification.notificationReceivedForeground = { [unowned self] _ in
            self.localNotificationReceivedForeground?()
        }
        
        if UserDefaults.standard.bool(forKey: Constants.Key.UserDefaults.AppInitiated) == false {
            Logger.MSG("Initiating Local Notification Data")
            
            localNotification.removeAllPendingNotifications()
            UserDefaults.standard.set(true, forKey: Constants.Key.UserDefaults.AppInitiated)
        }
    }
    
    // Find reminder object by using `number`
    private func findReminderBy(number: Int32) -> Reminder? {
        let reminders = sphere.object(Reminder.self).filter(NSPredicate(format: "number == %d", number)).sorted([NSSortDescriptor(key: "number", ascending: true)])
        if reminders.count > 0, let reminder = reminders.first {
            return reminder
        }
        
        return nil
    }
    
    // Find reminder object by using `unique id`
    private func findReminderBy(uniqueId: String) -> Reminder? {
        if let reminder = sphere.object(Reminder.self).filter(NSPredicate(format: "uniqueId == %@", uniqueId)).first {
            return reminder
        }
        
        return nil
    }
    
    // Clean date generation
    private func trim(time: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        let components = DateComponents(year: 2000, month: 1, day: 1, hour: timeComponents.hour, minute: timeComponents.minute)
        
        if let result = calendar.date(from: components) { return result }
        return time
    }
    
    // Get local notification identifiers
    func notificationIdsBy(uniqueId: String) -> [String] {
        guard let reminder = findReminderBy(uniqueId: uniqueId) else { return [] }
        
        let days = reminder.days?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as! [RDay]
        let times = reminder.times?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as! [RTime]
        var results: [String] = []
        
        for time in times {
            for day in days {
                if let dayId = day.uniqueId, let timeId = time.uniqueId {
                    results.append("\(dayId)\(timeId)".hash.description)
                }
            }
        }
        
        return results
    }
    
    // Get unique id
    func reminderUniqueIdBy(number: Int32) -> String? {
        return findReminderBy(number: number)?.uniqueId
    }
    
    /// Add New Reminder
    func insertReminder(number: Int32, title: String, color: Data, repeatType: Enumerated.Repeat, times: [Date], days: [Date], weekdays: [Int], monthdays: [Int]) {
        Logger.MSG("System) Insert Reminder")
        
        var timesParameter: [RTime] = []
        var daysParameter: [RDay] = []
        let reminderUniqueId = generateUniqueId()
        
        try! sphere.write { [unowned self] _ in
            for (index, time) in times.enumerated() {
                let item = self.sphere.add(RTime.self)!
                item.uniqueId = self.generateUniqueId()
                item.number = Int32(index) + 1
                item.time = self.trim(time: time) as NSDate
                timesParameter.append(item)
            }
            
            if repeatType == .norepeat {
                for (index, date) in days.enumerated() {
                    let item = self.sphere.add(RDay.self)!
                    item.uniqueId = self.generateUniqueId()
                    item.number = Int32(index) + 1
                    item.date = date as NSDate
                    daysParameter.append(item)
                }
            }
                
            else if repeatType == .week {
                for (index, weekday) in weekdays.enumerated() {
                    let item = self.sphere.add(RDay.self)!
                    item.uniqueId = self.generateUniqueId()
                    item.number = Int32(index) + 1
                    item.weekday = Int16(weekday)
                    daysParameter.append(item)
                }
            }
                
            else if repeatType == .month {
                for (index, day) in monthdays.enumerated() {
                    let item = self.sphere.add(RDay.self)!
                    item.uniqueId = self.generateUniqueId()
                    item.number = Int32(index) + 1
                    item.day = Int16(day)
                    item.endOfMonth = false
                    daysParameter.append(item)
                }
            }
            
            self.sphere.add(Reminder.self) {
                $0.uniqueId = reminderUniqueId
                $0.createdAt = NSDate()
                $0.updatedAt = NSDate()
                $0.number = number
                $0.title = title
                $0.color = color as NSData
                $0.ring = true
                $0.times = NSSet(array: timesParameter)
                $0.days = NSSet(array: daysParameter)
                $0.repeatType = Int16(repeatType.rawValue)
                $0.registered = true
            }
        }
        
        // Request new notifications
        requestLocalNotifications(reminder: reminderUniqueId)
    }
    
    /// Modify Existing Reminder
    func modifyReminder(number: Int32, title: String, color: Data, repeatType: Enumerated.Repeat, times: [Date], days: [Date], weekdays: [Int], monthdays: [Int]) {
        Logger.MSG("System) Modify Reminder")
        
        guard let reminder = findReminderBy(number: number) else { return }
        
        // Remove current notifications
        removeLocalNotifications(reminder: reminder.uniqueId)
        
        var timesParameter: [RTime] = []
        var daysParameter: [RDay] = []
        
        let predicate = NSPredicate(format: "reminder == %@", reminder)
        let timesToBeRemoved = sphere.object(RTime.self).filter(predicate)
        let daysToBeRemoved = sphere.object(RDay.self).filter(predicate)
        
        try! sphere.write { [unowned self] _ in
            
            for time in timesToBeRemoved { self.sphere.delete(time) }
            for day in daysToBeRemoved { self.sphere.delete(day) }
            
            for (index, time) in times.enumerated() {
                let item = self.sphere.add(RTime.self)!
                item.uniqueId = self.generateUniqueId()
                item.number = Int32(index) + 1
                item.time = self.trim(time: time) as NSDate
                timesParameter.append(item)
            }
            
            if repeatType == .norepeat {
                for (index, date) in days.enumerated() {
                    let item = self.sphere.add(RDay.self)!
                    item.uniqueId = self.generateUniqueId()
                    item.number = Int32(index) + 1
                    item.date = date as NSDate
                    daysParameter.append(item)
                }
            }
                
            else if repeatType == .week {
                for (index, weekday) in weekdays.enumerated() {
                    let item = self.sphere.add(RDay.self)!
                    item.uniqueId = self.generateUniqueId()
                    item.number = Int32(index) + 1
                    item.weekday = Int16(weekday)
                    daysParameter.append(item)
                }
            }
                
            else if repeatType == .month {
                for (index, day) in monthdays.enumerated() {
                    let item = self.sphere.add(RDay.self)!
                    item.uniqueId = self.generateUniqueId()
                    item.number = Int32(index) + 1
                    item.day = Int16(day)
                    item.endOfMonth = false
                    daysParameter.append(item)
                }
            }
            
            reminder.updatedAt = NSDate()
            reminder.title = title
            reminder.times = NSSet(array: timesParameter)
            reminder.days = NSSet(array: daysParameter)
            reminder.repeatType = Int16(repeatType.rawValue)
            reminder.registered = true
        }
        
        // Request new notifications
        if reminder.ring {
            requestLocalNotifications(reminder: reminder.uniqueId)
        }
    }
    
    /// Delete Reminder
    func deleteReminder(uniqueId: String) {
        Logger.MSG("System) Delete Reminder")
        
        removeLocalNotifications(reminder: uniqueId)
        
        guard let reminder = findReminderBy(uniqueId: uniqueId) else { return }
        
        try! sphere.write { [unowned self] _ in self.sphere.delete(reminder) }
    }
    
    /// Find next date for local notifications
    func nextNotificationDateForReminder(uniqueId: String) -> Date? {
        guard let reminder = findReminderBy(uniqueId: uniqueId) else { return nil }
        
        let now = Date()
        let calendar = Calendar.current
        
        let repeatType = Enumerated.Repeat(rawValue: Int(reminder.repeatType))!
        let days = reminder.days?.sortedArray(using: [NSSortDescriptor(key: "date", ascending: true)]) as! [RDay]
        let times = reminder.times?.sortedArray(using: [NSSortDescriptor(key: "time", ascending: true)]) as! [RTime]
        let timesParameter = times.map { $0.time! as Date }
        
        if repeatType == .day {
            if let next = compareTimes(day: now, times: timesParameter, now: now) { return next }
            return compareTimes(day: now.date(byAdding: .day, value: 1), times: timesParameter, now: now)!
        }
        
        var nextDates: [Date] = []
        
        for day in days {
            let baseDate = now.date(byAdding: .day, value: -1)
            var components = DateComponents(hour: 0)
            if repeatType == .norepeat {
                let dayParameter = day.date! as Date
                if let found = compareTimes(day: dayParameter, times: timesParameter, now: now) {
                    nextDates.append(found)
                    continue
                }
            }
                
            else if repeatType == .week {
                components = DateComponents(weekday: Int(day.weekday) + 1)
            }
                
            else if repeatType == .month {
                if day.endOfMonth {
                    components = DateComponents(day: 1)
                } else {
                    components = DateComponents(day: Int(day.day))
                }
                
            }
            
            var next = calendar.nextDate(after: baseDate, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
            
            if let _ = next, repeatType == .month && day.endOfMonth {
                next = calendar.date(byAdding: .day, value: -1, to: next!)
            }
            
            if let next = next {
                if let found = compareTimes(day: next, times: timesParameter, now: now) {
                    nextDates.append(found)
                } else if repeatType != .norepeat {
                    if let another = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) {
                        let found = compareTimes(day: another, times: timesParameter, now: now)
                        nextDates.append(found!)
                    }
                }
            }
        }
        
        if let result = nextDates.sorted(by: <).first {
            return result
        }
        
        return nil
    }
    
    private func compareTimes(day: Date, times: [Date], now: Date) -> Date? {
        let calendar = Calendar.current
        
        for time in times {
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: day)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            let components = DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day, hour: timeComponents.hour, minute: timeComponents.minute)
            let candidate = calendar.date(from: components)
            
            if let candidate = candidate, candidate > now {
                return candidate
            }
        }
        
        return nil
    }
    
    /// Generate unique id for Local Notifications
    func generateUniqueId() -> String {
        let timestamp = Int(Date().timeIntervalSince(self.baseDate) * 100000)
        let prefix = generateRandomString(length: 3)
        return "\(prefix)\(timestamp.description)"
    }
    
    /// Request local notification using reminder's unique id
    func requestLocalNotifications(reminder: String?) {
        if let reminder = reminder, let item = sphere.object(Reminder.self).filter(NSPredicate(format: "uniqueId == %@", reminder)).first {
            
            let predicate = NSPredicate(format: "reminder == %@", item)
            let times = sphere.object(RTime.self).filter(predicate).fetch()
            let days = sphere.object(RDay.self).filter(predicate).fetch()
            
            let repeatType = Enumerated.Repeat(rawValue: Int(item.repeatType))!
            
            var dayParameter: [(String, Any?, Bool)] = []
            
            if repeatType == .norepeat {
                dayParameter = days.map({ (identifier: $0.uniqueId!, day: $0.date as Any?, endOfMonth: $0.endOfMonth) })
            }
                
            else if repeatType == .week {
                dayParameter = days.map({ (identifier: $0.uniqueId!, day: $0.weekday as Any?, endOfMonth: $0.endOfMonth) })
            }
                
            else if repeatType == .month {
                dayParameter = days.map({ (identifier: $0.uniqueId!, day: $0.day as Any?, endOfMonth: $0.endOfMonth) })
            }
            
            localNotification
                .requestNotification(body: item.title!,
                                     repeatType: repeatType,
                                     days: dayParameter,
                                     times: times.map({ (identifier: $0.uniqueId!, time: $0.time! as Date) }),
                                     completion: { [unowned self] success in
                                        try! self.sphere.write { item.registered = success } })
        }
    }
    
    /// Remove local notification using reminder's unique id
    func removeLocalNotifications(reminder: String?) {
        if let reminder = reminder, let item = sphere.object(Reminder.self).filter(NSPredicate(format: "uniqueId == %@", reminder)).first {
            
            let predicate = NSPredicate(format: "reminder == %@", item)
            let timesToBeRemoved = sphere.object(RTime.self).filter(predicate)
            let daysToBeRemoved = sphere.object(RDay.self).filter(predicate)
            
            var identificationsToBeRemoved: [String] = []
            
            for time in timesToBeRemoved {
                if daysToBeRemoved.count == 0, let timeId = time.uniqueId {
                    identificationsToBeRemoved.append(timeId.hash.description)
                    continue
                }
                
                for day in daysToBeRemoved {
                    if let timeId = time.uniqueId, let dayId = day.uniqueId {
                        let identifier = "\(dayId)\(timeId)".hash.description
                        print("delete request: \(identifier)")
                        identificationsToBeRemoved.append(identifier)
                    }
                }
            }
            
            localNotification.removeNotification(identifiers: identificationsToBeRemoved)
        }
    }
    
    /// Generate random string of given length using defined key characters
    private func generateRandomString(length: UInt) -> String {
        let count = UInt32(keyCharacters.characters.count)
        var result = ""
        
        for _ in 0..<length {
            let randomNumber = Int(arc4random_uniform(count))
            let randomIndex = keyCharacters.index(keyCharacters.startIndex, offsetBy: randomNumber)
            let newCharacter = keyCharacters[randomIndex]
            result += String(newCharacter)
        }
        return result
    }
    
    /// Retrieve an encryption key from the keychain or generate a new one if not found
    private func retrieveEncryptionKey() -> String {
        let keychain = Keychain(service: Constants.Key.Service)
        
        if let key = keychain[string: Constants.Key.Encryption] {
            Logger.MSG("[keychain] Encryption key found: \(key)")
            return key
        } else {
            // Key not found in the keychain: reset SystemSetting
            let newKey = generateRandomString(length: 32)
            Logger.MSG("[keychain] Encryption key does not exist, issued a random key: \(newKey)")
            
            keychain[Constants.Key.Encryption] = newKey
            try! sphere.write { [unowned self] _ in self.sphere.deleteAll(SystemSetting.self) }
            Logger.MSG("[coredata] SystemSetting removed")
            return newKey
        }
    }
    
    /// Get theme info from Coredata(SystemSetting)
    private var _theme: SNTheme? = nil
    var theme: SNTheme {
        if let t = _theme { return t }
        else {
            let keyString = self.retrieveEncryptionKey()
            var result = defaultTheme
            
            if let setting = self.sphere.object(SystemSetting.self).first {
                Logger.MSG("[coredata] System setting record found, updated at \(String(describing: setting.updatedAt?.description)), with salt: \(String(describing: setting.salt))")
                
                let salt = setting.salt!
                let data = [UInt8](setting.theme! as Data)
                
                let key = PBKDF.deriveKey(password: keyString, salt: salt, prf: .sha256, rounds: 1, derivedKeyLength: 32)
                let cryptor = Cryptor(operation: .decrypt, algorithm: .aes, options: [.ECBMode, .PKCS7Padding], key:key, iv: Array<UInt8>())
                let decrypted = cryptor.update(byteArray: data)?.final()
                let decryptedString = decrypted!.reduce("") { $0 + String(UnicodeScalar($1)) }
                Logger.MSG("[cryptor] Decrypted theme id: \(decryptedString)")
                
                if let found = Constants.Theme.find(byId: decryptedString) {
                    Logger.MSG("[theme] Found the theme using id: \(found.id)")
                    result = found
                } else {
                    Logger.MSG("[theme] Failed to find theme, returning the default theme...")
                    result = defaultTheme
                }
            } else {
                Logger.MSG("[coredata] System setting record does not exist, creating a default setting...")
                
                let salt = self.generateRandomString(length: 8)
                let key = PBKDF.deriveKey(password: keyString, salt: salt, prf: .sha256, rounds: 1, derivedKeyLength: 32)
                let cryptor = Cryptor(operation: .encrypt, algorithm: .aes, options: [.ECBMode, .PKCS7Padding], key: key, iv: Array<UInt8>())
                let encrypted = cryptor.update(string: defaultTheme.id)?.final()
                let encryptedThemeIdData = Data(bytes: encrypted!) //NSData(bytes: encrypted!, length: encrypted!.count)
                
                try! sphere.write { [unowned self] _ in
                    self.sphere.add(SystemSetting.self) {
                        $0.salt = salt
                        $0.theme = encryptedThemeIdData as NSData
                        $0.updatedAt = NSDate()
                    }
                }
                result = defaultTheme
            }
            
            _theme = result
            return result
        }
    }
    
    /// Change theme & post notification
    func change(theme newTheme: SNTheme) {
        let keyString = self.retrieveEncryptionKey()
        
        if let setting = self.sphere.object(SystemSetting.self).first {
            Logger.MSG("[theme] Changing system theme: \(newTheme.id))")
            
            let salt = self.generateRandomString(length: 8)
            let key = PBKDF.deriveKey(password: keyString, salt: salt, prf: .sha256, rounds: 1, derivedKeyLength: 32)
            let cryptor = Cryptor(operation: .encrypt, algorithm: .aes, options: [.ECBMode, .PKCS7Padding], key: key, iv: Array<UInt8>())
            let encrypted = cryptor.update(string: newTheme.id)?.final()
            let encryptedThemeIdData = Data(bytes: encrypted!)
            
            try! sphere.write {
                setting.salt = salt
                setting.theme = encryptedThemeIdData as NSData
                setting.updatedAt = NSDate()
            }
            
            _theme = newTheme
            NotificationCenter.default.post(name: Constants.Identifier.Notification.ThemeChanged, object: newTheme)
            
        } else {
            Logger.MSG("[coredata] System setting record does not exist, theme change failed. aborting...")
        }
    }
    
    
    
    // MARK: - DEBUG FUNCTIONS
    func resetKeychain() {
        Logger.MSG("[keychain] info removed: \(Constants.Key.Encryption)")
        let keychain = Keychain(service: Constants.Key.Service)
        keychain[Constants.Key.Encryption] = nil
    }
}

extension SNSystem: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    /// In-App Purchase check state
    func purchaseDate(_ title: String) -> Date? {
        if let purchase = self.sphere.object(Purchase.self).filter(NSPredicate(format: "title == %@", title)).first {
            return purchase.createdAt as Date?
        }
        return nil
    }
    
    func requestProductsInfo(completion block: (([SKProduct]?) -> Void)?) {
        self.productRequestResponseBlock = block
        
        self.productRequest = SKProductsRequest(productIdentifiers: [Constants.Key.IAP.ThemePack.product])
        self.productRequest?.delegate = self
        self.productRequest?.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            self.products = response.products
            self.productRequestResponseBlock?(response.products)
        } else {
            self.productRequestResponseBlock?(nil)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func buyThemePack() {
        if let themePack = self.products.first {
            let payment = SKPayment(product: themePack)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    /// Observer
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        paymentNotification(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            Logger.MSG("Restore failed")
            return
        }
        
        paymentNotification(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                Logger.MSG("Transaction Error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func paymentNotification(identifier: String) {
        guard identifier == Constants.Key.IAP.ThemePack.product else { return }
        
        if let purchase = self.sphere.object(Purchase.self).filter(NSPredicate(format: "title == %@", Constants.Key.IAP.ThemePack.title)).first {
            try! self.sphere.write {
                purchase.createdAt = NSDate()
            }
        } else {
            try! self.sphere.write {
                self.sphere.add(Purchase.self) {
                    $0.title = Constants.Key.IAP.ThemePack.title
                    $0.createdAt = NSDate()
                }
            }
        }
        
        NotificationCenter.default.post(name: Constants.Identifier.Notification.PaymentQueueUpdated, object: nil)
    }
}
