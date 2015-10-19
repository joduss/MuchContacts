//
//  TestNetworkAndObjects.swift
//  TestAPI
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import XCTest
import Foundation

@testable import MuchContacts

class TestNetworkAndObjects: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let expectation = expectationWithDescription("wait for logout")
        
        apiHelper.logout( { _ in
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }
    
    
    /// test to create one contact instance from json data
    func testOneContactFromJSON() {
        let p = NSBundle(forClass:object_getClass(self)).pathForResource("jsonContactTest", ofType: "json")
        let jsonContactData = NSData(contentsOfFile: p!)
        
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonContactData!, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>
            
            let c = APIJSONProcessing.parseContactFromJSONDictionary(jsonObject)
            XCTAssertEqual(c?.firstname, "Adwaittest123")
            XCTAssertEqual(c?.lastname, "Adwait123")
            
            
        }
        catch _ {
            XCTAssert(false, "error with json because of TEST")
        }
    }
    
    
    /// test to create may contact instances from json data
    //test that the sorting function by lastname works
    //Test phone number as well
    func testManyContactsFromJSON() {
        let p = NSBundle(forClass:object_getClass(self)).pathForResource("jsonManyContactTest", ofType: "json")
        
        let jsonContactData = NSData(contentsOfFile: p!)
        
        let contacts = APIJSONProcessing.parseResponseGetAllContact(jsonContactData!) as Array<Contact>!
        
        XCTAssertEqual(4, contacts.count)
        XCTAssertEqual(contacts[0].lastname, "AAA")
        XCTAssertEqual(contacts[1].lastname, "Bob")
        
        XCTAssertEqual(contacts.last?.lastname, "Zoro")
        XCTAssertEqual(contacts.last?.phones.count, 2)
        XCTAssertEqual(contacts.last?.phones[1].type, "mobile")
        XCTAssertEqual(contacts.last?.phones[0].type, "mobile")
        XCTAssertEqual(contacts.last?.phones[0].type, "mobile")
        
        XCTAssertEqual(contacts[0].phones[0].type, "mobile")
        XCTAssertEqual(contacts[0].phones[1].type, "work")
        
        XCTAssertEqual(contacts.last?.phones[0].type, "mobile")
        XCTAssertEqual(contacts.last?.phones[1].type, "mobile")
        
        XCTAssert(contacts.last?.emails[0].address == "jo@k.com" || contacts.last?.emails[1].address == "jo@k.com")
    }
    
    /** One dictionary for a contact is corrupted*/
    func testManyContactsFromCorruptedJSON() {
        let p = NSBundle(forClass:object_getClass(self)).pathForResource("jsonCorruptedManyContactTest", ofType: "json")
        let jsonContactData = NSData(contentsOfFile: p!)
        let contacts = APIJSONProcessing.parseResponseGetAllContact(jsonContactData!)
        XCTAssertEqual(nil, contacts?.count)
        
    }
    
    
    //Test a correct login
    func testLoginCorrect(){
        
        let expectation = expectationWithDescription("Waiting on loggin")
        apiHelper.login(username: "jonathan.duss@bluewin.ch", password: "jonathan", completion: {(loggedIn, wrongCredentials) in
            XCTAssert(loggedIn)
            XCTAssertFalse(wrongCredentials)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(50, handler: nil)
    }
    
    //Test a case with wrong password
    func testLoginWrongPassword() {
        let expectation = expectationWithDescription("Waiting on loggin")
        apiHelper.login(username: "jonathan.duss@bluewin.ch", password: "jo", completion: {(loggedIn, wrongCredentials) in
            XCTAssertFalse(loggedIn)
            XCTAssert(wrongCredentials)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(50, handler: nil)
        
    }
    
    //Test to login then logout
    func testLoginLogout(){
        XCTAssertFalse(apiHelper.loggedIn)
        
        let expectation = expectationWithDescription("Waiting on loggin")
        apiHelper.login(username: "jonathan.duss@bluewin.ch", password: "jonathan", completion: {(loggedIn, wrongCredentials) in
            XCTAssert(loggedIn)
            XCTAssert(apiHelper.loggedIn)
            XCTAssertFalse(wrongCredentials)
            apiHelper.logout({(success) in
                XCTAssert(success)
                XCTAssertFalse(apiHelper.loggedIn)
                expectation.fulfill()
            })
        })
        waitForExpectationsWithTimeout(50, handler: nil)
    }
    
    //Test if the download of contacts works correctly
    //For that, is download all contact and check if a test contact exists
    func testDownloadContact() {
        let expectation = expectationWithDescription("Waiting on loggin")
        apiHelper.login(username: "jonathan.duss@bluewin.ch", password: "jonathan", completion: {(loggedIn, wrongCredentials) in
            XCTAssert(loggedIn)
            XCTAssertFalse(wrongCredentials)
            
            apiHelper.getAllContacts(0, completionHandler: {(contacts) in
                var testContactFound = false
                var testCompanyFound = false
                for contact in contacts {
                    print("contact: \(contact.firstname), \(contact.lastname)")
                    if(contact.firstname == "Existing" && contact.lastname == "Guy"){
                        testContactFound = true
                        XCTAssert(contact.contactType == ContactType.PERSON)
                        XCTAssert(contact.companyName == nil)
                    }
                    else if(contact.contactType == ContactType.COMPANY && contact.companyName == "TestCompany"){
                        testCompanyFound = true
                        XCTAssert(contact.contactType == ContactType.COMPANY)
                    }
                }
                XCTAssert(testContactFound)
                XCTAssert(testCompanyFound)
                
                expectation.fulfill()
            })
        })
        waitForExpectationsWithTimeout(50, handler: nil)
    }
    
    
    //Test that the interaction for a contact can be downloaded
    //test that the parsing is done correctly
    //That that the information parsed are correct and complete
    func testDownloadInteraction() {
        let expectation = expectationWithDescription("waiting")
        apiHelper.login(username: "softswiss@gmail.com", password: "jonathan", completion: {(loggedIn, wrongCredentials) in
            XCTAssert(loggedIn)
            
            //Now get the contacts to find the ID for Jonathan Bluewin
            apiHelper.getAllContacts(0, completionHandler: {(contacts) in
                var testContactFound = false
                 var desiredContact = Contact()
                for contact in contacts {
                    print("contact: \(contact.firstname), \(contact.lastname)")
                    if(contact.firstname == "Test" && contact.lastname == "Interaction"){
                        testContactFound = true
                        desiredContact = contact
                    }
                }
                XCTAssert(testContactFound)
                
                //if contact ID not found, abord
                guard testContactFound == true else {
                    return
                }
                
                //now load the interactions
                apiHelper.getAllInteractionWithContact(desiredContact, completionHandler:{(interactions) in
                    print("\(interactions)")
                    XCTAssertEqual(interactions.count, 4)
                    
                    //check that one number called for that contact is +41707998080
                    var numberFound = false
                    for inter in interactions {
                        if(inter.phoneNumber == "+41705005050") {
                            numberFound = true
                            XCTAssertEqual(inter.type, InteractionType.CALL)
                            XCTAssertEqual(inter.direction,InteractionDirection.OUTBOUND)
                        }
                        
                    }
                    XCTAssert(numberFound)
                    
                    
                    expectation.fulfill()
                })
                
                
            })
            
        })
        waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    //Test to download interaction with empty contact information
    //It should return an empty array
    func testInteractionWithEmptyContact() {
        let expectation = expectationWithDescription("waiting")
        apiHelper.login(username: "softswiss@gmail.com", password: "jonathan", completion: {(loggedIn, wrongCredentials) in
            XCTAssert(loggedIn)
            apiHelper.getAllInteractionWithContact(Contact(), completionHandler:{(interactions) in
                print("\(interactions)")
                XCTAssertEqual(interactions.count, 0)
                expectation.fulfill()
            })
        })
        waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    
    
    //Test to add interaction in the server
    func testInteractionCreation() {
        let expectation = expectationWithDescription("waiting")
        apiHelper.login(username: "softswiss@gmail.com", password: "jonathan", completion: {(loggedIn, wrongCredentials) in
            XCTAssert(loggedIn)
            
            
            //Will add interaction to "Writing Interaction"
            apiHelper.getAllContacts(0, completionHandler: {(contacts) in
                var desiredContact = Contact()
                var found = false
                for contact in contacts {
                    if(contact.firstname == "Writing" && contact.lastname == "Interaction"){
                        desiredContact = contact
                        found = true
                    }
                }
                XCTAssert(found)
                let newInteraction = Interaction(interactionDirection: InteractionDirection.INBOUND,
                    type: InteractionType.SMS,
                    date: Int64(CFAbsoluteTimeGetCurrent()),
                    phoneNumber: "+41706006060",
                    contactID: desiredContact.contactID!)
                
                apiHelper.createInteraction(newInteraction, completionHandler:{success in
                    XCTAssert(success)
                    expectation.fulfill()
                })
                
            })
            
        })
        waitForExpectationsWithTimeout(20, handler: nil)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
