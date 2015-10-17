//
//  Contact.swift
//  TestAPI
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import Foundation


class PhoneNumber : NSObject {
    var number : String
    var type:String
    
    
    init(number : String, type:String) {
        self.number = number
        self.type = type
        super.init()
    }
}

class EmailAddress : NSObject {
    var address : String
    var type:String
    init(address : String, type:String) {
        self.address = address
        self.type = type
        super.init()
    }
}

public enum ContactType {
    case COMPANY
    case PERSON
    
    static func stringToEnum(withString string:String) -> ContactType {
        if(string == APIJSONProcessing.CONTACT_TYPE_COMPANY){
            return ContactType.COMPANY
        }
        else if(string == APIJSONProcessing.CONTACT_TYPE_PERSON) {
            return ContactType.PERSON
        }
        else {
            NSException(name: "ENUM VALUE NOT FOUND", reason: "The given enum string \(string) does not correspond to any value of ContactType", userInfo: nil).raise()
            abort()
        }
    }
}

class Contact: NSObject {
    
    var firstname : String?
    var lastname : String?
    var companyName : String?
    var emails : [EmailAddress]
    var phones : [PhoneNumber]
    var contactType : ContactType?
    
    
    

    
    override init() {
        emails = Array<EmailAddress>()
        phones = Array<PhoneNumber>()
        super.init()
    }
    
    
    

    
}
