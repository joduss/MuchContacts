//
//  HTTPComm.swift
//  Friendly
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit


/**Handle the sending of the request to the server. It setup the header for json
* and the appropriate http method*/
class HTTPComm: NSObject {
    
    
    //Send actually the request to the server
    private class func send(session session: NSURLSession, request: NSMutableURLRequest, completionHandler handler:(NSData?, NSURLResponse?, NSError?) -> Void) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request, completionHandler: handler)
        task.resume()
    }
    
    //Send a post request
    class func postJSON(session session: NSURLSession, request: NSMutableURLRequest, completionHandler handler:(NSData?, NSURLResponse?, NSError?) -> Void) {
        //only set the POST HTTPMethod
        request.HTTPMethod = "POST"
        send(session: session, request: request, completionHandler: handler)
    }
    
    
    //Send a get request
    class func getJSON(session session: NSURLSession, request: NSMutableURLRequest, completionHandler handler:(NSData?, NSURLResponse?, NSError?) -> Void) {
        //only set the GET HTTPMethod
        request.HTTPMethod = "GET"
        send(session: session, request: request, completionHandler: handler)
    }
    
    
    //Send a put request
    class func putJSON(session session: NSURLSession, request: NSMutableURLRequest, completionHandler handler:(NSData?, NSURLResponse?, NSError?) -> Void) {
        //only set the GET HTTPMethod
        request.HTTPMethod = "PUT"
        send(session: session, request: request, completionHandler: handler)
    }
    
    
    
    //Hack: Contact google website to check internet availability
    class func sendRequestToGoogle(completionHandle: (success : Bool) -> Void) {
        let url = NSURL(string: "https://www.google.com")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        let task = {(data : NSData?, response : NSURLResponse?, error : NSError?) in
            if let _ = response as? NSHTTPURLResponse {
                completionHandle(success: true)
                
            }
            else {
                //no response: problem of internet most likely
                completionHandle(success: false)
            }
        }
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: task).resume()
    }
    

    
}
