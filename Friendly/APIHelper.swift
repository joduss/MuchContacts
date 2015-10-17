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
    
    //CONST used in the JSON by the API
    static let RESPONSE_TOKEN_OBJECT_KEY = "token"
    static let TOKEN_AUTHTOKEN_KEY = "authToken"
    static let TOKEN_EXPIRATION_KEY = "expires"
    

    
    
    private var username : String? = "softswiss@gmail.com"
    //private var password : String? = "jonathan"
    private var authToken : String?
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
            let session = NSURLSession.sharedSession()
            
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
                            completion?(loggedIn: true, wrongCredentials:false)
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
        
        let contacts = Array<Contact>()
        
        print("SEND REQUEST for contact\n")
        let url = NSURL(string: baseUrl + "/contacts?&offset=\(offset)&limit=1000")
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        //Test that the user is loggedIn and the token is not nil
        guard let authToken = authToken where loggedIn == true else {
            //Not logged in
            completionHandler(contacts: contacts)
            return
        }
        
        request.addValue(authToken, forHTTPHeaderField: APIHelper.TOKEN_AUTHTOKEN_KEY)
        
        
        let task = { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            print("RESPONSE CONTACT \(response))")
            
            do {
                if let contactsData = try NSJSONSerialization.JSONObjectWithData(data!,
                    options: NSJSONReadingOptions.AllowFragments)["data"] as? Array<Dictionary<String, AnyObject>> {
                        
                    let contactsLoaded = APIJSONProcessing.multipleContactsFromJSONContactArray(contactsData)
                        completionHandler(contacts: contactsLoaded)
                        // TODO adapt to get all contact
                }
                else {
                    printe("Error with the data")
                    completionHandler(contacts: contacts)
                }
            }
            catch _ {
                //cannot load, send empty array or contacts
                // TODO: notify user
                completionHandler(contacts: contacts)
            }
        }
        
        HTTPComm.getJSON(session: session, request: request, completionHandler: task)
    }
    
    
}



//let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())


//    do {
//    //prepare request
//    let userInfo = ["username" : username, "password" : password]
//    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(userInfo, options: NSJSONWritingOptions.PrettyPrinted)
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.addValue("application/json", forHTTPHeaderField: "Accept")
//    request.HTTPMethod = "POST"
//
//
//    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//
//    if(error != nil) {
//    print("Error: \(error?.localizedDescription)")
//    }
//    if let jsonRawData = data{
//    //Data were received. Try to get the authToken
//    print("Response received")
//    do {
//    let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonRawData, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>
//    if let tokenDico = jsonObject[self.RESPONSE_TOKEN_OBJECT_KEY]  {
//    self.authToken = tokenDico[self.TOKEN_AUTHTOKEN_KEY] as! String
//    self.expire = tokenDico[self.TOKEN_EXPIRATION_KEY] as! Int
//    print("authToken:\(self.authToken)")
//    self.getContact()
//    }
//    else {
//    print("error")
//    }
//    }
//    catch _ {
//    print("error")
//    }
//    }
//    else {
//    print("error")
//    }
//    })
//
//    task.resume()
//
//    }
//    catch _ {
//
//    }
//







