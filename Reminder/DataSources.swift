//
//  DataSources.swift
//  Reminder
//
//  Created by Sahn Cha on 05/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

struct DataSources {
    
    // MARK: - Settings
    struct Settings {
        typealias Row = (title: String, icon: UIImage?, detail: String?, type: Cell, segue: String?)
        
        static let sections: [Section] = [.app, .libraries, .review]
        
        static func find(sectionIndex: Int) -> Section? {
            for item in sections {
                if item.rawValue == sectionIndex { return item }
            }
            return nil
        }
        
        static func find(indexPath: IndexPath) -> Row? {
            if let section = find(sectionIndex: indexPath.section) {
                return section.rows[indexPath.row]
            }
            return nil
        }
        
        enum Cell: String {
            case basicContinue = "BasicContinueCell"
            case buttonExternal = "ButtonExternalCell"
        }
        
        enum Section: Int {
            case app = 0, libraries, review
            
            var title: String? {
                switch self {
                case .app: return "Application"
                case .libraries: return nil
                case .review: return "App Store"
                }
            }
            
            var rows: [Row] {
                switch self {
                case .app:
                    return [(title: "", icon: #imageLiteral(resourceName: "App24"), detail: "Reminder: S", type: .basicContinue, segue: Constants.Identifier.Segue.SettingApp),
                            (title: "Theme", icon: #imageLiteral(resourceName: "Palette24"), detail: SNSystem.defaultInstance.theme.title, type: .basicContinue, segue: Constants.Identifier.Segue.SettingTheme)]
                    
                case .libraries:
                    return [(title: "Libraries", icon: #imageLiteral(resourceName: "OpenSource24"), detail: nil, type: .basicContinue, segue: Constants.Identifier.Segue.SettingLibraries)]
                    
                case .review:
                    return [(title: "Write a review", icon: nil, detail: Constants.AppStoreURL, type: .buttonExternal, segue: nil)]
                }
            }
        }
    }
    
    // MARK: - Settings: Application
    struct SettingApp {
        typealias Row = (title: String, icon: UIImage?, detail: String?, type: Cell)
        
        static func find(sectionIndex: Int) -> Section? {
            for item in sections {
                if item.rawValue == sectionIndex { return item }
            }
            return nil
        }
        
        static func find(indexPath: IndexPath) -> Row? {
            if let section = find(sectionIndex: indexPath.section) {
                return section.rows[indexPath.row]
            }
            return nil
        }
        
        enum Cell: String {
            case basic = "BasicCell"
        }
        
        static let sections: [Section] = [.info, .soncode, .sahncha, .seonhokim, .resources]
        
        enum Section: Int {
            case info = 0, soncode, sahncha, seonhokim, resources
            
            var title: String? {
                switch self {
                case .info: return Constants.ApplicationName
                case .soncode: return "Handmade by"
                case .sahncha: return "Sahn Cha"
                case .seonhokim: return "Seonho Kim"
                case .resources: return "Resources"
                }
            }
            
            var rows: [Row] {
                switch self {
                case .info:
                    return [(title: "version", icon: nil, detail: Constants.ApplicationVersion, type: .basic),
                            (title: "build", icon: nil, detail: Constants.ApplicationBuild, type: .basic)]
                    
                case .soncode:
                    return [(title: "", icon: #imageLiteral(resourceName: "Hand24"), detail: "soncode.com", type: .basic)]
                    
                case .sahncha:
                    return [(title: "", icon: #imageLiteral(resourceName: "Twitter24"), detail: "@scha00", type: .basic),
                            (title: "", icon: #imageLiteral(resourceName: "Email24"), detail: "scha@jooae.com", type: .basic)]
                    
                case .seonhokim:
                    return [(title: "", icon: #imageLiteral(resourceName: "Email24"), detail: "seonho.net@gmail.com", type: .basic)]
                    
                case .resources:
                    return [(title: "Icons8", icon: #imageLiteral(resourceName: "Icons824"), detail: "icons8.com", type: .basic)]
                }
            }
        }
    }
    
    // MARK: - Settings: Theme
    struct SettingTheme {
        typealias Row = (title: String, detail: String, type: Cell)
        
        static func find(sectionIndex: Int) -> Section? {
            for item in sections {
                if item.rawValue == sectionIndex { return item }
            }
            return nil
        }
        
        static func find(indexPath: IndexPath) -> Row? {
            if let section = find(sectionIndex: indexPath.section) {
                return section.rows[indexPath.row]
            }
            return nil
        }
        
        enum Cell: String {
            case theme = "ThemeSelectCell"
            case buttonPurchase = "ThemePurchaseCell"
            case buttonRestore = "ThemeRestoreCell"
        }
        
        static let sections: [Section] = [.main, .themePack, .purchase, .restore]
        
        enum Section: Int {
            case main = 0, themePack, purchase, restore
            
            var title: String? {
                switch self {
                case .main: return "Default"
                case .themePack: return "Theme Pack"
                case .purchase: return "Purchase"
                case .restore: return ""
                }
            }
            
            var rows: [Row] {
                switch self {
                case .main:
                    return [(title: "Stripes", detail: Constants.Theme.Basic.id, type: .theme)]
                    
                case .themePack:
                    return [(title: "Candy", detail: Constants.Theme.Candy.id, type: .theme),
                            (title: "Dancheong", detail: Constants.Theme.Dancheong.id, type: .theme),
                            (title: "Lavender", detail: Constants.Theme.Lavender.id, type: .theme),
                            (title: "Citrus Grove", detail: Constants.Theme.CitrusGrove.id, type: .theme),
                            (title: "Winter Night", detail: Constants.Theme.WinterNight.id, type: .theme),
                            (title: "Reds", detail: Constants.Theme.Reds.id, type: .theme),
                            (title: "Golden Greens", detail: Constants.Theme.GoldenGreens.id, type: .theme),
                            (title: "The Iron", detail: Constants.Theme.TheIron.id, type: .theme)]
                    
                case .purchase:
                    return [(title: "Theme pack", detail: "loading", type: .buttonPurchase)]
                    
                case .restore:
                    return [(title: "Restore Purchases", detail: "", type: .buttonRestore)]
                }
            }
        }
    }
    
    // MARK: - Add Reminder: Repeat Type Picker
    struct Repeat {
        static let items: [Enumerated.Repeat] = [.norepeat, .day, .week, .month]
    }
    
}
