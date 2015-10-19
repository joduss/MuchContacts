//
//  APIJSONProcessing.swift
//  Friendly
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit

/**Provides parsing functions the json objects that are received*/
class APIJSONProcessing: NSObject {
    
    //keys used in the json dictionary
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
    
    static let ID_KEY = "id"
    
    
    static let CREATED_KEY = "created"
    static let INTERACTION_CONTACTS = "contacts"
    static let INTERACTION_DIRECTION = "direction"
    static let INTERACTION_FROM = "from"
    static let INTERACTION_TO = "to"
    static let INTERACTION_TYPE = "type"
    static let INTERACTION_DURATION = "duration"
    
    static let TRIGGER_TOKEN_KEY = "triggerToken"
    static let TRIGGER_TOKEN_ENTITY_KEY = "entity"
    
    //set some properties
    static let MAX_EMAIL_ADDRESSES_DOWNLOAD = 2
    
    
    //================================
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
    
    //================================
    /** Create a Contact object from the information specified in the dictionary*/
    class func parseContactFromJSONDictionary(jsonDico : Dictionary<String, AnyObject>) -> Contact?{
        let newContact = Contact()
        
        guard let ct = jsonDico[CONTACT_TYPE_KEY] as? String,
            contactType = ContactType(rawValue:ct) else {
                //cannot know the contact type. Error in the data!
                return nil
        }
        
        newContact.firstname = jsonDico[FIRSTNAME_JSON] as? String
        newContact.lastname = jsonDico[LASTNAME_JSON] as? String
        newContact.contactType = contactType
        newContact.companyName = jsonDico[COMPANY_NAME_KEY] as? String
        newContact.contactID = (jsonDico[ID_KEY] as! String)
        
        if let emailsRecords = (jsonDico[EMAIL_JSON] as? Array<Dictionary<String, String>>) {
            
            var i = 0
            while(i < MAX_EMAIL_ADDRESSES_DOWNLOAD && i < emailsRecords.count){
                let record = emailsRecords[i]
                if let address = record[EMAIL_RECORD_EMAIL_ADDRESS], type = record[EMAIL_RECORD_EMAIL_TYPE]
                {
                    let emailAddress =
                    newContact.emails.append(EmailAddress(address: address, type: type))
                }
                i++
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
    
    
    //================================
    /** Create contacts objects with the data specified in the json array*/
    class func parseMultipleContactsFromJSONContactArray(jsonArray : Array<Dictionary<String, AnyObject>>) -> [Contact]{
        var newContacts = Array<Contact>()
        for dic in jsonArray {
            if let contactToLoad = parseContactFromJSONDictionary(dic) {
                newContacts.append(contactToLoad)
            }
            
        }
        
        //sort alphabetically
        newContacts.sortInPlace({(el1, el2) in
            let s1 = el1.getBestNameForSorting()
            let s2 = el2.getBestNameForSorting()
            return s1.lowercaseString < s2.lowercaseString
        })
        return newContacts
    }
    
    
    //================================
    /**Parse the datat received after doing a request to get all the contacts */
    class func parseResponseGetAllContact(data : NSData) -> [Contact]? {
        do {
            if let rawContactArray = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments)["data"] as? Array<Dictionary<String, AnyObject>> {
                    return APIJSONProcessing.parseMultipleContactsFromJSONContactArray(rawContactArray)
            }
            else {
                printe("Error with the data")
            }
        }
        catch _ {
            printd("Error while parsing json to Dictionary")
            // TODO: notify user instead of just sending a empty array
        }
        return nil
    }
    
    
    
    //================================
    /**
    Parse a JSON describing one interaction into a Interaction object
    */
    class func parseJSONInteractionToInteractionObject(jsonDico : Dictionary<String, AnyObject>) -> Interaction? {
        
        //Check that some field exist and are not nil. Otherwise, problem with the data and the parsing is interrupted
        //and returns nil
        
        //check date and that there is a contact specified as callee or caller
        
        guard let date = jsonDico[CREATED_KEY] as? NSTimeInterval,
            contacts = jsonDico[INTERACTION_CONTACTS] as? Array<Dictionary<String,AnyObject>>
            where contacts.count > 0
            else {
                return nil
        }
        print("cn: \(contacts.count)")
        
        
        //Check if the id for that contact is specified
        guard let contactID = contacts[0][ID_KEY] as? String else {
            return nil
        }
        
        guard let type = jsonDico[INTERACTION_TYPE] as? String,
            interactionType = InteractionType(rawValue: type) else {
                return nil
        }
        
        //Check that the direction of the interaction exists, and more over
        //that the value is OUTBOUND or INBOUND
        guard let direction = jsonDico[INTERACTION_DIRECTION] as? String,
            interactionDirection = InteractionDirection(rawValue: direction) else {
                return nil
        }
        
        //Check that phone numbers (to/from) exist
        
        var contactPhoneNumber : String?
        let fromPhoneNumber = jsonDico[INTERACTION_FROM] as? String
        let toPhoneNumber = jsonDico[INTERACTION_TO] as? String
        
        //In inbound => toPhoneNumber is nil
        //For outbound, fromPhoneNumber is nil
        if let number = fromPhoneNumber where interactionDirection == InteractionDirection.INBOUND {
            contactPhoneNumber = number
        }
        if let number = toPhoneNumber where interactionDirection == InteractionDirection.OUTBOUND {
            contactPhoneNumber = number
        }
        
        //check that the phone number is not nil
        guard let phoneNumber = contactPhoneNumber else {
            return nil
        }
        
        //duration is nil if it's sms, not nil if it's a call
        let duration = jsonDico[INTERACTION_DURATION] as? Int
        
        
        return Interaction(interactionDirection: interactionDirection,
            type: interactionType,
            date: date,
            phoneNumber: phoneNumber,
            contactID: contactID,
            duration:duration)
    }
    
    
    //================================
    //    /**
    //    Part a json containing many interactions into an array of Interaction objects
    //    */
    //    class func parseJSONArrayOfInteractions(jsonArray : Array<Dictionary<String, AnyObject>>) -> [Interaction] {
    //
    //
    //        var interactions = Array<Interaction>()
    //        for dic in jsonArray {
    //            if let interaction = parseJSONInteractionToInteractionObject(dic) {
    //                interactions.append(interaction)
    //            }
    //        }
    //        return interactions
    //    }
    
    
    //================================
    /*Parse the response that is received when requesting the list of interaction with a contact */
    class func parseResponseGetInteractionWithContact(data : NSData) -> [Interaction]? {
        do {
            if let interactionData = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments)["data"] as? Array<Dictionary<String, AnyObject>> {
                    
                    var interactions = Array<Interaction>()
                    for dic in interactionData {
                        if let interaction = parseJSONInteractionToInteractionObject(dic) {
                            interactions.append(interaction)
                        }
                    }
                    return interactions
            }
            else {
                printe("Error with the data")
            }
        }
        catch _ {
            printd("Error while parsing json to Dictionary")
            // TODO: notify user instead of just sending a empty array
        }
        return nil
    }
    
    
    //================================
    /**Parse the response when requesting a trigger token*/
    class func parseTriggerToken(jsonRawData : NSData?) -> String? {
        guard let data = jsonRawData else {
            return nil
        }
        do {
            guard let jsonDico = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject> else {
                return nil
            }
            
            if(jsonDico[TRIGGER_TOKEN_KEY] != nil) {
                return jsonDico[TRIGGER_TOKEN_KEY] as? String
            }
            else {
                return jsonDico[TRIGGER_TOKEN_ENTITY_KEY]?[TRIGGER_TOKEN_KEY] as? String
            }
        }
        catch _ {
            return nil
        }
    }
    
    
    
    
}
