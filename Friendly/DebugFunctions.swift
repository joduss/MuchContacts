//
//  SwiftDebugGlobalFunctions.swift
//  
//
//  Created by Jonathan Duss on 18.07.14.
//  Copyright (c) 2014 Jonathan Duss. All rights reserved.
//

//import Foundation
import UIKit
import Foundation


//Global constant


//Just for debug stuff
#if DEBUG
    func printd(a : String){print("#DD  | " + a, terminator: ""); print("\n", terminator: "")}
    func debugAlertView(message : String) {
        UIAlertView(title: "DEBUG: ERROR", message: message, delegate: nil, cancelButtonTitle: "ok").show()
    }
    #else
    func printd(msg : String){}
    func debugAlertView(message : String) {}
#endif


//LOG A LOT
#if EXTREME_LOG
    func printextr(msg : String){ print(msg, terminator: "\n")}
    #else
    func printextr(msg : String){}
#endif


//LOG WHAT IS USEFULL
#if LOG
    func printl(msg : String){ print("#L   | "+msg, terminator: "\n")}
    #else
    func printl(msg : String){}
#endif

func printe(msg: String) {print("❌ ERROR - \(msg)", terminator: "\n")}
