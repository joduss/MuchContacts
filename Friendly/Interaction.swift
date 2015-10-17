//
//  Activity.swift
//  MuchContacts
//
//  Created by Jonathan on 17/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit

enum InteractionDirection : String {
    case INBOUND = "INBOUND"
    case OUTBOUND = "OUTBOUND"
}

enum InteractionType : String {
    case CALL = "call"
    case SMS = "sms"
}

/**
*   Class representing one interaction between the user and one contact
*
*/
class Interaction: NSObject {

    let direction : InteractionDirection
    let type : InteractionType
    let date : Int64
    
    //known by the system
    let contactID : String
    
    let phoneNumber : String
    
    let duration : Int? //only for phone. For SMS will be nil
    
    
    init(interactionDirection direction:InteractionDirection, type:InteractionType, date: Int64, phoneNumber:String, contactID:String, duration : Int? = nil) {
        self.direction = direction
        self.type = type
        self.date = date
        self.phoneNumber = phoneNumber
        self.contactID = contactID
        self.duration = duration
        super.init()
    }

    
    
}
