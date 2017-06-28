//
//  Logger.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import Foundation

public class Logger {
    
    class func MSG(functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
        Logger.MSG(nil, functionName: functionName, fileNameWithPath: fileNameWithPath, lineNumber: lineNumber)
    }
    
    class func MSG(_ message: Any?, functionName:  String = #function, fileNameWithPath: String = #file, lineNumber: Int = #line ) {
        #if DEBUG
            var msg = ""
            if let m = message { msg = String(describing: m) }
            let file = fileNameWithPath.components(separatedBy: "/").last!
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSSS"
            let dateString = dateFormatter.string(from: date)
            
            let output = "(\(dateString)) \(file) [\(lineNumber)] \(functionName)> \(msg)"
            print(output)
        #endif
    }
    
}
