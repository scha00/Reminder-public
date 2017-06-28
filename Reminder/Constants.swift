//
//  Constants.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

struct Constants {
    static let ApplicationName = "Reminder: S"
    static let AppStoreURL = "itms://itunes.apple.com/app/reminder-s/id1245159072"
    
    static var ApplicationVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var ApplicationBuild: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    static let Storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    static func Title(count: Int) -> String {
        if count == 0 { return "Reminder: S" }
        else if count == 1 { return "1 Reminder" }
        else { return "\(count) Reminders" }
    }
    
    struct Screen {
        static let Size = UIScreen.main.bounds.size
        static let Width = Constants.Screen.Size.width
        static let Height = Constants.Screen.Size.height
    }
    
    // MARK: - System colors
    struct Color {
        struct Cell {
            static let GrayedOutBackground = #colorLiteral(red: 0.9137254902, green: 0.9137254902, blue: 0.9137254902, alpha: 1)
            static let GrayedOutForeground = #colorLiteral(red: 0.5382495241, green: 0.5382495241, blue: 0.5382495241, alpha: 1)
            
            static let SettingTitle = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
            static let SettingDetail = #colorLiteral(red: 0.4549019608, green: 0.4549019608, blue: 0.4549019608, alpha: 1)
            static let SettingSectionBackground = #colorLiteral(red: 0.9688121676, green: 0.9688346982, blue: 0.9688225389, alpha: 1)
            static let SettingMicroTitle = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        }
        
        struct Input {
            static let AddTitleText = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
        }
        
        struct Icon {
            static let InactiveBell = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            static let TrashBin = #colorLiteral(red: 0.9253047705, green: 0.2199100554, blue: 0.1773960888, alpha: 1)
            static let Done = #colorLiteral(red: 0.9253047705, green: 0.2199100554, blue: 0.1773960888, alpha: 1)
        }
        
        static let SystemBlue = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
    // Theme candidates
//    SNTheme("Fall",
//    id: "Fall-id",
//    backgroundColors: [#colorLiteral(red: 0.7211049795, green: 0.4033360481, blue: 0.6552026272, alpha: 1), #colorLiteral(red: 0.3026008308, green: 0.2547879219, blue: 0.5895012617, alpha: 1), #colorLiteral(red: 0.5852436423, green: 0.5663439631, blue: 0.5140386224, alpha: 1), #colorLiteral(red: 0.7167066932, green: 0.2168481648, blue: 0.2340449989, alpha: 1), #colorLiteral(red: 0.3092660308, green: 0.367800653, blue: 0.259729147, alpha: 1)],
//    lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
//    darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
//    SNTheme("B5395",
//    id: "B5395-id",
//    backgroundColors: [#colorLiteral(red: 0, green: 0.1407494247, blue: 0.3013375103, alpha: 1), #colorLiteral(red: 0, green: 0.1407494247, blue: 0.3013375103, alpha: 1), #colorLiteral(red: 0, green: 0.1407494247, blue: 0.3013375103, alpha: 1), #colorLiteral(red: 0, green: 0.1407494247, blue: 0.3013375103, alpha: 1), #colorLiteral(red: 0, green: 0.1407494247, blue: 0.3013375103, alpha: 1)],
//    lightForegroundColor: #colorLiteral(red: 0.8897795348, green: 0.8911028184, blue: 0.966126658, alpha: 1),
//    darkForegroundColor: #colorLiteral(red: 0.8897795348, green: 0.8911028184, blue: 0.966126658, alpha: 1)),
//    SNTheme("Pastel",
//    id: "Pastel-id",
//    backgroundColors: [#colorLiteral(red: 0.8368722796, green: 0.8160942197, blue: 0.9149330854, alpha: 1), #colorLiteral(red: 0.7981051207, green: 0.888282001, blue: 0.9494188428, alpha: 1), #colorLiteral(red: 0.8993222117, green: 0.9380751848, blue: 0.9167422652, alpha: 1), #colorLiteral(red: 0.9309081435, green: 0.963340342, blue: 0.8856860995, alpha: 1), #colorLiteral(red: 0.9853314757, green: 0.9607129693, blue: 0.8345098495, alpha: 1)],
//    lightForegroundColor: #colorLiteral(red: 0.04859829453, green: 0.06514187169, blue: 0.1566267449, alpha: 1),
//    darkForegroundColor: #colorLiteral(red: 0.04859829453, green: 0.06514187169, blue: 0.1566267449, alpha: 1)),
    
    // MARK: - Theme colors
    struct Theme {
        private static let list = [SNTheme("Stripes",
                                           id: "Basic-id",
                                           backgroundColors: [#colorLiteral(red: 0.5294117647, green: 0.1450980392, blue: 0.1490196078, alpha: 1), #colorLiteral(red: 0.1607843137, green: 0.2352941176, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 0.2235294118, green: 0.137254902, blue: 0.1137254902, alpha: 1), #colorLiteral(red: 0.3294117647, green: 0.2352941176, blue: 0.07450980392, alpha: 1), #colorLiteral(red: 0.06666666667, green: 0.3568627451, blue: 0.337254902, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Candy",
                                           id: "Candy-id",
                                           backgroundColors: [#colorLiteral(red: 0.3490196078, green: 0.368627451, blue: 0.4549019608, alpha: 1), #colorLiteral(red: 0.5254901961, green: 0.7803921569, blue: 0.8392156863, alpha: 1), #colorLiteral(red: 0.8509803922, green: 0.4745098039, blue: 0.3843137255, alpha: 1), #colorLiteral(red: 0.8823529412, green: 0.7568627451, blue: 0.2745098039, alpha: 1), #colorLiteral(red: 0.4117647059, green: 0.6745098039, blue: 0.4705882353, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Dancheong",
                                           id: "Dancheong-id",
                                           backgroundColors: [#colorLiteral(red: 0.1463966668, green: 0.2792054415, blue: 0.1979579329, alpha: 1), #colorLiteral(red: 0.3777849078, green: 0.6267659068, blue: 0.4318057895, alpha: 1), #colorLiteral(red: 0.9496119618, green: 0.8051549196, blue: 0.4295753241, alpha: 1), #colorLiteral(red: 0.9257606864, green: 0.5033274293, blue: 0.3073630929, alpha: 1), #colorLiteral(red: 0.7787963748, green: 0.2809036672, blue: 0.3264191747, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Lavender",
                                           id: "Lavender-id",
                                           backgroundColors: [#colorLiteral(red: 0.8650707603, green: 0.3009150326, blue: 0.4564671516, alpha: 1), #colorLiteral(red: 0.9755660892, green: 0.4224832356, blue: 0.230582118, alpha: 1), #colorLiteral(red: 0.9469072223, green: 0.6673156023, blue: 0.2185637951, alpha: 1), #colorLiteral(red: 0.2881934047, green: 0.4779474139, blue: 0.7548976541, alpha: 1), #colorLiteral(red: 0.7071681619, green: 0.6306588054, blue: 0.841124475, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Citrus Grove",
                                           id: "CitrusGrove-id",
                                           backgroundColors: [#colorLiteral(red: 0.8588235294, green: 0.3450980392, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5647058824, blue: 0, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.7764705882, blue: 0, alpha: 1), #colorLiteral(red: 0.5568627451, green: 0.631372549, blue: 0.02352941176, alpha: 1), #colorLiteral(red: 0.3490196078, green: 0.3882352941, blue: 0.1176470588, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Winter Night",
                                           id: "WinterNight-id",
                                           backgroundColors: [#colorLiteral(red: 0.003921568627, green: 0.06666666667, blue: 0.2509803922, alpha: 1), #colorLiteral(red: 0.007843137255, green: 0.09411764706, blue: 0.3490196078, alpha: 1), #colorLiteral(red: 0.007843137255, green: 0.1176470588, blue: 0.4509803922, alpha: 1), #colorLiteral(red: 0.1803921569, green: 0.3764705882, blue: 0.5490196078, alpha: 1), #colorLiteral(red: 0.003921568627, green: 0.1058823529, blue: 0.3882352941, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Reds",
                                           id: "Reds-id",
                                           backgroundColors: [#colorLiteral(red: 0.9156560302, green: 0.06504712999, blue: 0.1737626195, alpha: 1), #colorLiteral(red: 0.8425312638, green: 0.1558751166, blue: 0.1629743576, alpha: 1), #colorLiteral(red: 0.9173879027, green: 0.2980229855, blue: 0.2017813921, alpha: 1), #colorLiteral(red: 0.9411764706, green: 0.1490196078, blue: 0.2, alpha: 1), #colorLiteral(red: 0.6535136421, green: 0.1793526132, blue: 0.1854710304, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("Golden Greens",
                                           id: "GoldenGreens-id",
                                           backgroundColors: [#colorLiteral(red: 0.03921568627, green: 0.1294117647, blue: 0.06666666667, alpha: 1), #colorLiteral(red: 0.03921568627, green: 0.2392156863, blue: 0.06666666667, alpha: 1), #colorLiteral(red: 0.1568627451, green: 0.3803921569, blue: 0.09411764706, alpha: 1), #colorLiteral(red: 0.7294117647, green: 0.6, blue: 0.09019607843, alpha: 1), #colorLiteral(red: 0.8784313725, green: 0.7294117647, blue: 0.1333333333, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)),
                                   SNTheme("The Iron",
                                           id: "TheIron-id",
                                           backgroundColors: [#colorLiteral(red: 0.7098039216, green: 0.09019607843, blue: 0, alpha: 1), #colorLiteral(red: 0.8588235294, green: 0.2235294118, blue: 0.0431372549, alpha: 1), #colorLiteral(red: 0.9490196078, green: 0.568627451, blue: 0.1333333333, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.7137254902, blue: 0.06666666667, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.8549019608, blue: 0.003921568627, alpha: 1)],
                                           lightForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
                                           darkForegroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                                   ]
        
        static var Basic: SNTheme { return self.list[0] }
        static var Candy: SNTheme { return self.list[1] }
        static var Dancheong: SNTheme { return self.list[2] }
        static var Lavender: SNTheme { return self.list[3] }
        static var CitrusGrove: SNTheme { return self.list[4] }
        static var WinterNight: SNTheme { return self.list[5] }
        static var Reds: SNTheme { return self.list[6] }
        static var GoldenGreens: SNTheme { return self.list[7] }
        static var TheIron: SNTheme { return self.list[8] }
        
        static func find(byId id: String) -> SNTheme? {
            return self.list.filter { $0.id == id }.first
        }
    }
    
    // MARK: - System fonts
    struct Font {
        static let ReminderCellDate = UIFont(name: "AvenirNext-Regular", size: 10)
        static let ReminderCellTitle = UIFont(name: "AvenirNext-Regular", size: 16)
        
        static let AddTextFieldTitle = UIFont(name: "AvenirNext-Regular", size: 25)
        static let AddSaveButton = UIFont(name: "AvenirNext-Regular", size: 16)
        
        static let SettingCellTitle = UIFont(name: "AvenirNext-Regular", size: 16)
        static let SettingCellDetail = UIFont(name: "AvenirNext-Regular", size: 14)
        static let SettingCellMicro = UIFont(name: "AvenirNext-Regular", size: 12)
        
        static let LibraryTitle = UIFont.boldSystemFont(ofSize: 14)
        static let LibraryContent = UIFont.systemFont(ofSize: 12)
    }
    
    // MARK: - Reminder cells
    struct ReminderCell {
        static let CornerRadius: CGFloat = 2.0
        static let DefaultHeight: CGFloat = 65.0
        static let Padding: CGFloat = 8.0
        static var TitleRowHeight: CGFloat = {
            return "ABCDE".height(withConstrainedWidth: 300, font: Constants.Font.ReminderCellTitle!)
        }()
    }
    
    // MARK: - Identifiers
    struct Identifier {
        struct Notification {
            static let ThemeChanged = Foundation.Notification.Name("ThemeChangedNotification")
            static let PaymentQueueUpdated = Foundation.Notification.Name("PaymentQueueUpdatedNotification")
        }
        
        struct Segue {
            static let Add = "AddSegue"
            static let Modify = "ModifySegue"
            static let Setting = "SettingSegue"
            static let SettingApp = "SettingAppSegue"
            static let SettingTheme = "SettingThemeSegue"
            static let SettingLibraries = "SettingLibrariesSegue"
        }
    }
    
    // MARK: - Key codes
    struct Key {
        static let Service = "Reminder.SON"
        static let Encryption = "Keychain.Encryption"
        
        struct IAP {
            static let ThemePack = (title: "ThemePack", product: "com.soncode.reminder.themepack")
        }
        
        struct UserDefaults {
            static let AuthRequest = "Reminder.UserDefaults.AuthRequest"
            static let AppInitiated = "Reminder.UserDefaults.AppInitiated"
        }
    }
    
    // MARK: - Date formatters
    static func dateFormatter(_ format: String, locale : Locale = Locale.current) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        return dateFormatter
    }
    
    // MARK: - Sentence
    struct Sentence {
        static func addReminderTime(count: Int) -> String {
            switch count {
            case 0: return "-"
            case 1: return "Once a day"
            case 2: return "Twice a day"
            default: return "\(count) times a day"
            }
        }
        
        static func saveReminderButton(repeatType: Enumerated.Repeat, times: [Date], days: [Date], weekdays: [Int], monthdays: [Int]) -> (title: String, active: Bool) {
            
            let failed = (title: "Select dates for the reminder", active: false)
            
            let locale = Locale(identifier: "en_US")
            let timeFormatter = Constants.dateFormatter("h:mm a", locale: locale)
            let dateFormatter = Constants.dateFormatter("MMM d", locale: locale)
            let dateWithYearFormatter = Constants.dateFormatter("MMM d, yy", locale: locale)
            let calendar = NSCalendar.current
            
            var title = "Remind me at "
            for (index, time) in times.sorted(by: <).enumerated() {
                if index != 0 { title += ", " }
                title += "\(timeFormatter.string(from: time))"
            }
            
            title += " "
            
            switch repeatType {
            case .norepeat:
                if days.count == 0 { return failed }
                
                if days.count == 1 && (calendar.isDateInToday(days[0]) || calendar.isDateInTomorrow(days[0])) {
                    title += calendar.isDateInToday(days[0]) ? "today" : "tomorrow"
                    break
                }
                
                title += "on "
                for (index, day) in days.sorted(by: <).enumerated() {
                    if index != 0 { title += ", " }
                    if calendar.isDateInToday(day) {
                        title += "today"
                    } else if calendar.isDateInTomorrow(day) {
                        title += "tomorrow"
                    } else {
                        if calendar.component(.year, from: days[0]) == calendar.component(.year, from: Date()) {
                            title += dateFormatter.string(from: day)
                        } else {
                            title += dateWithYearFormatter.string(from: day)
                        }
                    }
                }
                
            case .day:
                title += "everyday"
                
            case .week:
                if weekdays.count == 0 { return failed }
                
                title += "on every "
                for (index, weekday) in weekdays.sorted(by: <).enumerated() {
                    if index != 0 { title += ", " }
                    title += Constants.dateFormatter("EEEE").weekdaySymbols[weekday]
                }
                
            case .month:
                if monthdays.count == 0 { return failed }
                
                title += "on "
                for (index, monthday) in monthdays.sorted(by: <).enumerated() {
                    if index != 0 { title += ", " }
                    if monthday == 11 || monthday == 12 || monthday == 13 { title += "\(monthday)th"; continue }
                    
                    if monthday % 10 == 1 {
                        title += "\(monthday)st"
                    } else if monthday % 10 == 2 {
                        title += "\(monthday)nd"
                    } else if monthday % 10 == 3 {
                        title += "\(monthday)rd"
                    } else {
                        title += "\(monthday)th"
                    }
                }
                
                title += " of every month"
                
            default:
                return failed
            }
            
            return (title: title, active: true)
        }
        
        static func reminderCellNextDateTitle(date: Date?) -> String? {
            guard let date = date else { return nil }
            
            let locale = Locale(identifier: "en_US")
            
            let calendar = NSCalendar.current
            let weekdayDateFormatter = Constants.dateFormatter("EEEE", locale: locale)
            let dateFormatter = Constants.dateFormatter("MMM d", locale: locale)
            let longDateFormatter = Constants.dateFormatter("MMM d, yyyy", locale: locale)
            let timeFormatter = Constants.dateFormatter("h:mm a", locale: locale)
            
            var result = ""
            if calendar.isDateInToday(date) {
                result += "Today"
            } else if calendar.isDateInTomorrow(date) {
                result += "Tomorrow"
            } else if calendar.dateComponents([.day], from: Date(), to: date).day! < 6 {
                result += weekdayDateFormatter.string(from: date)
            } else if calendar.dateComponents([.month], from: Date(), to: date).month! >= 11 {
                result += longDateFormatter.string(from: date)
            } else {
                result += dateFormatter.string(from: date)
            }
            
            result += "\n\(timeFormatter.string(from: date))"
            return result
        }
    }
    
    
    // -
    struct Test {
        static func cellTitle(_ words: Int) -> String {
            let hues = ["Dark Salmon", "Blue", "Teal", "Pink", "Blanched Almond", "Slate Gray", "White Smoke", "Tomato", "Dark Red", "Snow", "Red", "Medium Violet Red", "Black", "Gainsboro", "Slate Blue", "White", "Dim Gray", "Medium Orchid", "Light Green", "Peru"]
            let fruits = ["blueberry", "lime", "pomegranate", "orange", "cantaloupe", "pineapple", "nectarine", "honeydew", "clementine", "papaya", "date", "watermelon", "banana", "apple", "strawberry", "blackberry", "peach"]
            
            var title = hues[Int(arc4random_uniform(UInt32(hues.count - 1)))] + " " + fruits[Int(arc4random_uniform(UInt32(fruits.count - 1)))]
            
            for _ in 0..<words {
                title += " "
                title += fruits[Int(arc4random_uniform(UInt32(fruits.count - 1)))]
            }
            
            return title
        }
    }
}
