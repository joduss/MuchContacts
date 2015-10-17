//
//  APIJSONProcessing.swift
//  Friendly
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit

class APIJSONProcessing: NSObject {
    
    
    static let FIRSTNAME_JSON = "firstName"
    static let LASTNAME_JSON = "lastName"
    static let PHONENUMBERS_JSON = "phoneNumbers"
    static let EMAIL_JSON = "emails"
    static let EMAIL_RECORD_EMAIL_ADDRESS = "email"
    static let EMAIL_RECORD_EMAIL_TYPE = "type"
    static let PHONE_RECORD_NUMBER = "number"
    static let PHONE_RECORD_TYPE = "type"
    static let COMPANY_NAME_KEY = "companyName"
    
    static let CONTACT_TYPE_KEY = "contactType"
    static let CONTACT_TYPE_COMPANY = "COMPANY"
    static let CONTACT_TYPE_PERSON = "PERSON"
    

    //Read the json returned at the login and returns the AuthToken
    class func loginJSONProcessing(jsonRawData : NSData) -> (String, Int)? {
        
        do {
        let jsonDico = try NSJSONSerialization.JSONObjectWithData(jsonRawData, options: NSJSONReadingOptions.AllowFragments)
            if let tokenDico = jsonDico[APIHelper.RESPONSE_TOKEN_OBJECT_KEY] as? Dictionary<String, AnyObject> {
                let token = tokenDico[APIHelper.TOKEN_AUTHTOKEN_KEY] as! String
                let expire = tokenDico[APIHelper.TOKEN_EXPIRATION_KEY] as! Int
                return (token, expire)
            }
        } catch _ {
            return nil
        }
        return nil
    }
    
    //Create a contact from JSON Dictionary representing the contact
    class func contactFromJSONDictionary(jsonDico : Dictionary<String, AnyObject>) -> Contact?{
        let newContact = Contact()
        
        guard let contactType = jsonDico[CONTACT_TYPE_KEY] as? String else {
            //cannot know the contact type. Error in the data!
            return nil
        }
        newContact.firstname = jsonDico[FIRSTNAME_JSON] as? String
        newContact.lastname = jsonDico[LASTNAME_JSON] as? String
        newContact.contactType = ContactType.stringToEnum(withString: contactType)
        newContact.companyName = jsonDico[COMPANY_NAME_KEY] as? String

        
        if let emailsRecords = (jsonDico[EMAIL_JSON] as? Array<Dictionary<String, String>>) {
            for record in emailsRecords {
                if let address = record[EMAIL_RECORD_EMAIL_ADDRESS], type = record[EMAIL_RECORD_EMAIL_TYPE]
                {
                    newContact.emails.append(EmailAddress(address: address, type: type))
                }
            }
        }
        if let phoneNumbersRecords = (jsonDico[PHONENUMBERS_JSON] as? Array<Dictionary<String, String>>) {
            //phonenumbersRecords = array of dictionnary. Each containing the type of phone number and the phoe number
            
            for record in phoneNumbersRecords {
                if let type = record[PHONE_RECORD_TYPE], number = record[PHONE_RECORD_NUMBER] {
                    
                    let phoneNumber = PhoneNumber(number: number, type: type)
                    
                    //fill array with phones, mobile first.
                    if(type == "mobile" && newContact.phones.count != 0){
                        newContact.phones.insert(phoneNumber, atIndex: 0)
                    } else {
                        newContact.phones.append(phoneNumber)
                    }
                    
                    //Then remove to keep only 2. Mobile number are the firts. Want to keep
                    //mobile + another. So if there are other, first remove the additional mobile number.
                    //worst case: only phone numbers, and keep 2 of them
                    while(newContact.phones.count > 2) {
                        newContact.phones.removeAtIndex(1)
                    }
                }
            }
            
        }
        return newContact
    }
    
    //Create a contacts with the data specified in the json
    class func multipleContactsFromJSONContactArray(jsonArray : Array<Dictionary<String, AnyObject>>) -> [Contact]{
        var newContacts = Array<Contact>()
        for dic in jsonArray {
            if let contactToLoad = contactFromJSONDictionary(dic) {
                newContacts.append(contactToLoad)
            }
            
        }
        newContacts.sortInPlace({ $0.lastname < $1.lastname })
        return newContacts
    }
}
