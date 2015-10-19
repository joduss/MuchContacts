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

    /**Get the device ID. If is does not exists, generate one and save it.*/
    class func getDeviceIDForUsername(username : String) -> String{
        if let deviceID = JNKeychain.loadValueForKey(username) as? String {
            return deviceID
        }
        else {
            //The id may be a sensitive information (at least related to privacy).
            //Better to save it in the keychain
            let id = generateDeviceID()
            JNKeychain.saveValue(id, forKey: username)
            return id
        }
    }
    
    class func generateDeviceID() -> String{
        //generate unique ID:
        let max = UINT32_MAX
        let part1 = arc4random_uniform(max)
        let part2 = arc4random_uniform(max)
        let part3 = arc4random_uniform(max)
        let part4 = arc4random_uniform(max)

        return "\(part1)-\(part2)-\(part3)-\(part4)"
    }
    
    /**Return the number of seconds that have passed since 1970*/
    class func getCurrentTimeInSeconds() -> NSTimeInterval {
        return NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970
    }
}