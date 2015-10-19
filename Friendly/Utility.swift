//
//  StringExtension.swift
//  MuchContacts
//
//  Created by Jonathan on 17/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import Foundation


class Utility {
    
    
    class func stringNotNilNotEmpty(s : String?) -> Bool {
        return (s != nil && s != "")
    }

    
    class func generateDeviceID() -> String{
        //generate unique ID:
        let part1 = arc4random_uniform(100000)
        let part2 = arc4random_uniform(100000)
        let part3 = arc4random_uniform(100000)
        let part4 = arc4random_uniform(100000)

        return "\(part1)-\(part2)-\(part3)-\(part4)"
    }
    
    
    class func getCurrentTimeMilis() -> NSTimeInterval {
        return NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970
    }
}