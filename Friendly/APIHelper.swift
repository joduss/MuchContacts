//
//  APIHelper.swift
//  Friendly
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit


let apiHelper = APIHelper()

//This class handles communication with the Interact API
class APIHelper: NSObject {
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:nil, delegateQueue:NSOperationQueue.mainQueue())
    
    //CONST used in the JSON by the API
    static let RESPONSE_TOKEN_OBJECT_KEY = "token"
    static let TOKEN_AUTHTOKEN_KEY = "authToken"
    static let TOKEN_EXPIRATION_KEY = "expires"
    static let TRIGGEN_TOKEN_KEY = "triggerToken"
    
    
    
    private var username : String? = "softswiss@gmail.com"
    //private var password : String? = "jonathan"
    private var authToken : String?
    private var triggerToken : String?
    private var expire : Int?
    
    private(set) var loggedIn : Bool
    
    private let baseUrl = "https://api.mycontacts.io/v2"
    
    
    private override init(){
        loggedIn = false
        super.init()
    }
    
    class func helper() -> APIHelper {
        return apiHelper
    }
    
    
    /**
    Login
    */
    func login(username username: String, password: String, completion:((loggedIn: Bool, wrongCredentials: Bool)  -> Void)?=nil) {
        if(loggedIn == false) {
            self.username = username
            let requestUrl = NSURL(string: baseUrl + "/login")
            let request = NSMutableURLRequest(URL: requestUrl!)
            
            do {
                let bodyInfo = ["username" : username, "password" : password]
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyInfo, options: NSJSONWritingOptions.PrettyPrinted)
                
                let completionHandler = {
                    (data : NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                    
                    // TODO Handle case of errors
                    
                    //Handles the response
                    if(error != nil) {
                        printe("Error: error while loggin 1")
                        completion?(loggedIn:false, wrongCredentials:false)
                        return
                    }
                    
                    guard let jsonRawData = data else {
                        printe("Error login: no data")
                        completion?(loggedIn:false, wrongCredentials:false)
                        return
                    }
                    
                    guard let response = response else {
                        //no response
                        printe("Server response is nil")
                        completion?(loggedIn: false, wrongCredentials: false)
                        return
                    }
                    
                    switch (response as! NSHTTPURLResponse).statusCode {
                    case 401:
                        // 401 = wrong password or username
                        completion?(loggedIn: false, wrongCredentials:true)
                        printl("Wrong Credential")
                        break
                        
                    case 200:
                        //everything's great
                        if let (token, expire) = APIJSONProcessing.loginJSONProcessing(jsonRawData) {
                            printl("Loggin OK")
                            self.authToken = token
                            self.expire = expire
                            self.loggedIn = true
                            self.getTriggerToken(completion)
                            break
                        }
                    default:
                        printe("Error: other")
                        break
                    }
                    
                    printd("response: \(response)")
                }
                
                //Sent the request to the server
                HTTPComm.postJSON(session: session, request: request, completionHandler: completionHandler)
            }
            catch _ {
                // TODO: handle that case
                printe("FAIL TO SEND TO SERVER: cannot jsonieze the parameters")
                completion?(loggedIn: false, wrongCredentials: false)
                
            }
        }
        else {
            //Serious error
            // TODO HANDLE
            printe("SERIOUS ERROR: TRY TO LOGGIN AGAIN !!!!")
            completion?(loggedIn: false, wrongCredentials: false)
        }
    }
    
    
    /* Get the TriggerToken. If the device was not registered, it will be done*/
    private func getTriggerToken(completion:((loggedIn: Bool, wrongCredentials: Bool)  -> Void)?=nil) {
        let url = NSURL(string: baseUrl + "/triggerDevices?deviceId=iphone_access")
        let request = NSMutableURLRequest(URL: url!)
        
        
        let completionTask = {(data : NSData?, response: NSURLResponse?, error: NSError?) in
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            printd("data \(NSString(data: data!, encoding: NSUTF8StringEncoding))")
            
            
            
            switch statusCode {
            case 200:
                if let trigToken = APIJSONProcessing.parseTriggerToken(data) {
                    self.triggerToken = trigToken
                    completion?(loggedIn: true, wrongCredentials: false)
                } else {
                    completion?(loggedIn: false, wrongCredentials: false)
                }
                break
            case 401:
                //need to register the device
                self.registerDevice(completion)
                break
            default:
                // TODO HANDLE DIFFERENTLY
                completion?(loggedIn: false, wrongCredentials: false)
                break
            }
            
        }
        
        
        guard let authenticationToken = authToken else {
            completion?(loggedIn: false, wrongCredentials: false)
            return
        }
        
        request.addValue(authenticationToken, forHTTPHeaderField: APIHelper.TOKEN_AUTHTOKEN_KEY)
        HTTPComm.getJSON(session: session, request: request, completionHandler: completionTask)
        
        
    }
    
    /** Registers the device*/
    func registerDevice(completion:((loggedIn: Bool, wrongCredentials: Bool)  -> Void)?=nil) {
        let url = NSURL(string: baseUrl + "/triggerDevices")
        let request = NSMutableURLRequest(URL: url!)
        let completionTask = {(data : NSData?, response: NSURLResponse?, error: NSError?) in
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            printd("data \(NSString(data: data!, encoding: NSUTF8StringEncoding))")
            
            switch statusCode {
            case 201:
                if let trigToken = APIJSONProcessing.parseTriggerToken(data) {
                    self.triggerToken = trigToken
                    completion?(loggedIn: true, wrongCredentials: false)
                } else {
                    completion?(loggedIn: false, wrongCredentials: false)
                }
                break
            default:
                // TODO HANDLE DIFFERENTLY
                self.logout()
                completion?(loggedIn: false, wrongCredentials: false)
                break
            }
        }
        
        
        //set the body:
        let dataParam = ["deviceId" : "iphone_access", "name" : "iphone"]
        
        guard let authenticationToken = authToken else {
            completion?(loggedIn: false, wrongCredentials: false)
            return
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dataParam, options: NSJSONWritingOptions.PrettyPrinted)
            request.addValue(authenticationToken, forHTTPHeaderField: APIHelper.TOKEN_AUTHTOKEN_KEY)
            HTTPComm.putJSON(session: session, request: request, completionHandler: completionTask)
        }
        catch _ {
            completion?(loggedIn: false, wrongCredentials: false)
        }
        
    }
    
    
    /**
    Logout the user
    */
    func logout(completionHandler: ((success : Bool) -> Void)?=nil) {
        
        guard let token = authToken where loggedIn == true else {
            //else: nothing important. Should not be an error
            completionHandler?(success: true)
            return
        }
        
        let requestUrl = NSURL(string: baseUrl + "/logout")
        let request = NSMutableURLRequest(URL: requestUrl!)
        let session = NSURLSession.sharedSession()
        
        request.addValue(token, forHTTPHeaderField: APIHelper.TOKEN_AUTHTOKEN_KEY)
        
        let taskAfterCompletion = {
            (data : NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            guard let response = response as? NSHTTPURLResponse else {
                printe("Error logout failed , no answer from server")
                completionHandler?(success: false)
                return
            }
            //Whatever the response is, the user will be logged out.
            //If error, then the user was not logged in anymore
            //if(response.statusCode == 205) {
            printl("Logout succeeded")
            self.username = nil
            self.authToken = nil
            self.loggedIn = false
            self.expire = nil
            self.triggerToken = nil
            completionHandler?(success: true)
            //}
            
        }
        
        HTTPComm.postJSON(session: session, request: request, completionHandler: taskAfterCompletion)
    }
    
    
    
    
    
    /**
    Load 50 contacts on the server, starting from the offset'th.
    - parameter offset: What is the first contact to load
    - returns: An array with the downloaded contacts */
    func getAllContacts(offset:Int, completionHandler:((contacts : [Contact]) -> Void)){
        
        print("PREPARE SEND REQUEST for contact\n")
        let url = NSURL(string: baseUrl + "/contacts?&offset=\(offset)&limit=1000")
        let request = NSMutableURLRequest(URL: url!)
        
        //Test that the user is loggedIn and the token is not nil
        guard let authToken = authToken where loggedIn == true else {
            //Not logged in
            completionHandler(contacts: Array<Contact>())
            return
        }
        
        
        let completionTask = { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            print("RESPONSE CONTACT \(response))")
            do {
                if let contactsData = try NSJSONSerialization.JSONObjectWithData(data!,
                    options: NSJSONReadingOptions.AllowFragments)["data"] as? Array<Dictionary<String, AnyObject>> {
                        
                        let contactsLoaded = APIJSONProcessing.parseMultipleContactsFromJSONContactArray(contactsData)
                        completionHandler(contacts: contactsLoaded)
                        // TODO adapt to get all contact
                }
                else {
                    printe("Error with the data")
                    completionHandler(contacts: Array<Contact>())
                }
            }
            catch _ {
                //cannot load, send empty array or contacts
                // TODO: notify user
                completionHandler(contacts: Array<Contact>())
            }
        }
        
        request.addValue(authToken, forHTTPHeaderField: APIHelper.TOKEN_AUTHTOKEN_KEY)
        HTTPComm.getJSON(session: session, request: request, completionHandler: completionTask)
    }
    
    
    
    
    
    
    /** Returns all the interfactions that happened between the user and the specified contacts*/
    func getAllInteractionWithContact(contact : Contact, completionHandler:((interactions : [Interaction]) -> Void)) {
        
        print("PREPARE SEND REQUEST for INTERACTION with : \(contact.firstname) \(contact.lastname)\n")
        
        //the contact should have an id
        guard let contactID = contact.contactID else {
            //Nothing to do, return empty array
            completionHandler(interactions: Array<Interaction>())
            return
        }
        
        //If the token is missing
        guard let authToken = authToken else {
            //Not logged in
            completionHandler(interactions: Array<Interaction>())
            return
        }
        
        let url = NSURL(string: baseUrl + "/contacts/\(contactID)/interactions")
        let request = NSMutableURLRequest(URL: url!)
        
        let completionTask = { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            print("RESPONSE INTERACTION \(response))")
            do {
                if let interactionData = try NSJSONSerialization.JSONObjectWithData(data!,
                    options: NSJSONReadingOptions.AllowFragments)["data"] as? Array<Dictionary<String, AnyObject>> {
                        //print("data: \(interactionData)")
                        
                        let interactionLoaded = APIJSONProcessing.parseJSONArrayOfInteractions(interactionData)
                        completionHandler(interactions: interactionLoaded)
                        // TODO adapt to get all contact
                }
                else {
                    printe("Error with the data")
                    completionHandler(interactions: Array<Interaction>())
                }
            }
            catch _ {
                //cannot load, send empty array or interaction
                // TODO: notify user
                completionHandler(interactions: Array<Interaction>())
            }
        }
        
        request.addValue(authToken, forHTTPHeaderField: APIHelper.TOKEN_AUTHTOKEN_KEY)
        HTTPComm.getJSON(session: session, request: request, completionHandler: completionTask)
    }
    
    
    
    
    //Test creation of Interaction
    // TODO for call: update the interaction with the duration!
    func createInteraction(interaction : Interaction, completionHandler:((success : Bool) -> Void)?) {
        printd("Will be adding interaction")
        
        let url = NSURL(string: baseUrl + "/interactions")
        let request = NSMutableURLRequest(URL: url!)
        
        guard let token = triggerToken else {
            completionHandler?(success: false)
            return
        }
        
        
        // TODO HANDLE ERROR 401, 403, 409
        
        let completionTask = { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            print("Response for adding interaction \(response))")
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            //printd("data \(NSString(data: data!, encoding: NSUTF8StringEncoding))")
            
            switch statusCode {
            case 201:
                completionHandler?(success: true)
                break
            default:
                completionHandler?(success: false)
                break
            }
        }
        
        //Create the body with the information of the new interaction
        var fromToKey = ""
        if(interaction.direction == InteractionDirection.INBOUND) {
            fromToKey = "from"
        } else {
            fromToKey = "to"
        }
        let dataParam = [APIJSONProcessing.INTERACTION_DIRECTION : interaction.direction.rawValue,
            APIJSONProcessing.INTERACTION_TYPE : interaction.type.rawValue,
            fromToKey : interaction.phoneNumber]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(dataParam, options: NSJSONWritingOptions.PrettyPrinted)
            request.addValue(token, forHTTPHeaderField: APIHelper.TRIGGEN_TOKEN_KEY)
            
            
            HTTPComm.postJSON(session: session, request: request, completionHandler: completionTask)
        }
        catch _ {
            completionHandler?(success: false)
        }
    }

    
    
}




