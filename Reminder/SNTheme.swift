//
//  SNTheme.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import Hue

struct SNTheme {
    
    let id: String
    let title: String
    let backgroundColors: [UIColor]
    let lightForegroundColor: UIColor
    let darkForegroundColor: UIColor
    
    public init(_ title: String, id: String, backgroundColors bColors: [UIColor], lightForegroundColor lColor: UIColor, darkForegroundColor dColor: UIColor) {
        self.title = title
        self.id = id
        backgroundColors = (bColors.count == 0) ? [UIColor.red] : bColors
        lightForegroundColor = lColor
        darkForegroundColor = dColor
    }
    
    func extract(data: Data) -> UIColor {
        let color = SNThemeColor(data: data)
        return convert(themeColor: color)
    }
    
    func foregroundColor(forThemeColor color: SNThemeColor?) -> UIColor {
        guard let color = color else { return lightForegroundColor }
        
        let converted = convert(themeColor: color)
        if converted.isDark {
            return lightForegroundColor
        } else {
            return darkForegroundColor
        }
    }
    
    func backgroundColor(forThemeColor color: SNThemeColor?) -> UIColor {
        guard let color = color else { return backgroundColors.first! }
        
        return convert(themeColor: color)
    }
    
    func convert(themeColor color: SNThemeColor) -> UIColor {
        let count = backgroundColors.count
        let first = backgroundColors[Int(color.firstIndex) % count]
        let second = backgroundColors[Int(color.secondIndex) % count]
        let rate = CGFloat(color.mixRate)
        
        let r = (first.redComponent * (1.0 - rate) + (second.redComponent * rate))
        let g = (first.greenComponent * (1.0 - rate) + (second.greenComponent * rate))
        let b = (first.blueComponent * (1.0 - rate) + (second.blueComponent * rate))
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

/// Theme color component
struct SNThemeColor {
    
    var firstIndex: UInt
    var secondIndex: UInt
    var mixRate: Double {
        didSet {
            if mixRate > 1.0 { mixRate = 1.0 }
            else if mixRate < 0.0 { mixRate = 0.0 }
        }
    }
    
    init() {
        firstIndex = 0
        secondIndex = 0
        mixRate = 0.0
    }
    
    init(first: UInt, second: UInt, rate: Double) {
        firstIndex = first
        secondIndex = second
        mixRate = (rate > 1.0) ? 1.0 : ((rate < 0.0) ? 0.0 : rate)
    }
    
    init(data: Data) {
        self.init()
        if let tuple = read(data: data) {
            firstIndex = tuple.0
            secondIndex = tuple.1
            mixRate = (tuple.2 > 1.0) ? 1.0 : ((tuple.2 < 0.0) ? 0.0 : tuple.2)
        }
    }
    
    static func fromData(_ data: Data?) -> SNThemeColor? {
        guard let data = data else { return nil }
        return SNThemeColor(data: data)
    }
    
    var data: Data {
        return Data(bytes: [UInt8(firstIndex), UInt8(secondIndex), UInt8(mixRate * 100)])
    }
    
    static func generateThemeColor(exclude colors: [Data]?, indexCount count: Int) -> SNThemeColor {
        guard let colors = colors else { return randomThemeColor(indexCount: count) }
        
        let data = colors.map { (data) -> (UInt, Double) in
            if let themeColor = SNThemeColor.fromData(data) { return (themeColor.firstIndex, themeColor.mixRate) }
            else { return (0, 0.0) }
        }
        
        var foundIndex: UInt? = nil
        for i in 0...(count - 1) {
            if (!data.contains { Int($0.0) == i && $0.1 == 0.0 }) {
                foundIndex = UInt(i)
                break
            }
        }
        
        if let found = foundIndex {
            return SNThemeColor(first: found, second: found, rate: 0.0)
        } else {
            return randomThemeColor(indexCount: count)
        }
    }
    
    static private func randomThemeColor(indexCount count: Int) -> SNThemeColor {
        let firstIndex = UInt(arc4random_uniform(UInt32(count)))
        let secondIndex = UInt(arc4random_uniform(UInt32(count)))
        let mixRate = Double(arc4random_uniform(100)) / 100.0
        return SNThemeColor(first: firstIndex, second: secondIndex, rate: mixRate)
    }
    
    /// Read data-typed color
    private func read(data: Data) -> (UInt, UInt, Double)? {
        let array = [UInt8](data)
        if array.count < 3 { return nil }
        else {
            return (UInt(array[0]), UInt(array[1]), Double(array[2]) / 100.0)
        }
    }
}
