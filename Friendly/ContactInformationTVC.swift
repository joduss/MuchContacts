//
//  ContactInformationTVC.swift
//  MuchContacts
//
//  Created by Jonathan on 18/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit
import JGProgressHUD
import MessageUI

class ContactInformationTVC: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    var contact : Contact?
    var allContact = Array<Contact>()
    
    private var interactions = Array<Interaction>()
    
    private var callStartTime = 0.0
    private var phoneNumberInUse : String?
    
    
    private var hud = JGProgressHUD()
    
    override func viewDidLoad() {
        //setup hud style
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView.init(HUDStyle: hud.style)
        
        super.viewDidLoad()
        
        //show progresshud
        hud.showInView(self.navigationController?.view, animated: true)
        self.loadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    func loadData() {
        apiHelper.getAllInteractionWithContact(contact!, completionHandler: {interactions in
            self.interactions = interactions
            self.tableView.reloadData()
            self.hud.dismissAnimated(true)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = contact {
            return 2
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        guard let c = contact else {
            return 0
        }
        
        if( section == 0) {
            var numberOfInfo = 1 //1 for the name/firstname
            if let mails = contact?.emails {
                numberOfInfo += mails.count
                
            }
            if let phones = contact?.phones {
                numberOfInfo += phones.count
            }
            return numberOfInfo
        }
        else if(section == 1){
            return interactions.count
        }
        return 0
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 1) {
            return "Past interactions"
        }
        return nil
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if(indexPath.section == 0){
            return prepareCellForSection0(tableView, forIndexPath: indexPath)
        } else if(indexPath.section == 1){
            return prepareCellForSection1ForActivity(tableView, forIndexPath: indexPath)
        }
        let cell = UITableViewCell()
        
        
        return cell
    }
    
    
    /**Prepare a cell for the section 0*/
    func prepareCellForSection0(tv : UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //init a default cell
        var cell = UITableViewCell()
        guard let c = contact else {
            return cell //return the cell without configuring it
        }
        
        if(indexPath.row == 0){
            cell = tableView.dequeueReusableCellWithIdentifier("twoNamesCell", forIndexPath: indexPath)
            let labelFirstname = cell.viewWithTag(1) as! UILabel
            let labelLastname = cell.viewWithTag(2) as! UILabel
            if(contact?.companyName != nil){
                //it's a company
                labelFirstname.text = contact?.companyName
                labelLastname.text = nil
            } else {
                labelFirstname.text = contact?.firstname
                labelLastname.text = contact?.lastname
            }
        }
        else if(indexPath.row >= 1 && indexPath.row < 1 + c.emails.count) {
            cell = tableView.dequeueReusableCellWithIdentifier("emailCell", forIndexPath: indexPath)
            let emailAddresslabel = cell.viewWithTag(1) as! UILabel
            let emailAddressType = cell.viewWithTag(2) as! UILabel
            let email = c.emails[indexPath.row - 1]
            emailAddresslabel.text = email.address
            emailAddressType.text = email.type
        }
        else if(indexPath.row >= 1 + c.emails.count && indexPath.row <= 1 + c.emails.count + c.phones.count){
            cell = tableView.dequeueReusableCellWithIdentifier("phoneCell", forIndexPath: indexPath)
            let phoneNumberLabel = cell.viewWithTag(1) as! UILabel
            let phoneNumberTypeLabel = cell.viewWithTag(2) as! UILabel
            let phone = c.phones[indexPath.row - (1 + c.emails.count)]
            phoneNumberLabel.text = phone.number
            phoneNumberTypeLabel.text = phone.type
        }
        
        return cell
    }
    
    func prepareCellForSection1ForActivity(tv : UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let interaction = interactions[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("interactionCell", forIndexPath: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let directionLabel = cell.viewWithTag(2) as! UILabel
        let nameLabel = cell.viewWithTag(3) as! UILabel
        let interactionNumberLabel = cell.viewWithTag(4) as! UILabel
        let dateLabel = cell.viewWithTag(5) as! UILabel
        
        
        if(interaction.type == InteractionType.CALL) {
            imageView.image = UIImage(named: "phone-icon")
        }
        else if(interaction.type == InteractionType.SMS) {
            imageView.image = UIImage(named: "sms")
        }
        
        if(interaction.direction == InteractionDirection.INBOUND) {
            directionLabel.text = "<"
        } else {
            directionLabel.text = ">"
        }
        
        if let interactionContact = findContactWithID(interaction.contactID) {
            
            nameLabel.text = interactionContact.nameToDisplay()
            interactionNumberLabel.text = interaction.phoneNumber
            
            //format the date:
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(interaction.date / 1000)) //Should be seconds. So convert ms to s.
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            formatter.dateStyle = .LongStyle
            
            dateLabel.text = formatter.stringFromDate(date);
            
        }
        else {
            
        }
        
        
        return cell
    }
    
    
    func findContactWithID(contactID : String) -> Contact? {
        for c in allContact {
            if(c.contactID == contactID){
                return c
            }
        }
        return nil
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let c = contact where indexPath.section == 0 && indexPath.row != 0 {
            if(indexPath.row >= 1 && indexPath.row < 1 + c.emails.count) {
                //is an email
            } else if indexPath.row >= 1 + c.emails.count && indexPath.row <= 1 + c.emails.count + c.phones.count {
                
                //number with which an action will be made
                let phoneNumber = c.phones[indexPath.row - (1 + c.emails.count)].number
                self.phoneNumberInUse = phoneNumber

                
                //Show 2 options to the user when he clicks on a phone number: send sms or call
                let actionsheet = UIAlertController(title: "Send sms or call", message: "Choose the desired action", preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                //setup the call action
                actionsheet.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.Default, handler: {alertAction in
                    //this is making a call
                    UIApplication.sharedApplication().openURL(NSURL(string: "tel:\(phoneNumber)")!)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("callEnded"), name: "CALL", object: nil)
                    self.callStartTime = Utility.getCurrentTimeInSeconds()
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }))
                
                //setup the sms action
                actionsheet.addAction(UIAlertAction(title: "SMS", style: UIAlertActionStyle.Default, handler: {alertAction in
                    //this is to send an SMS
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    
                    let smsController = MFMessageComposeViewController()
                    smsController.recipients = [phoneNumber]
                    smsController.messageComposeDelegate = self
                    self.presentViewController(smsController, animated: true, completion: nil)
                    
                    
                }))
                
                //cancel action
                actionsheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {alertAction in
                    //cancel
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }))
                
                self.presentViewController(actionsheet, animated: true, completion: nil)
            }
        }
        else {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func callEnded() {
        
        if let contactID = contact?.contactID,
            number = phoneNumberInUse {
                let callStopTime = Utility.getCurrentTimeInSeconds()
                let duration = callStopTime - callStartTime
                
                let minutes = Int(duration / Double(60))
                let seconds = Int(duration - Double(minutes)*60.0)
                
                print("duration: \(minutes):\(seconds)")
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "CALL", object: nil)
                
                
                let newInteraction = Interaction(interactionDirection: InteractionDirection.OUTBOUND,
                    type: InteractionType.CALL,
                    date: Utility.getCurrentTimeInSeconds(),
                    phoneNumber: number, contactID: contactID)
                //show progresshud
                hud.showInView(self.navigationController?.view, animated: true)
                
                apiHelper.createInteraction(newInteraction, completionHandler: { success in
                    //TODO: Handle a failure
                    
                    //Reload the data to show the new interaction
                    self.loadData()
                })
                
                phoneNumberInUse = nil
        }
    }
    
    
    
    //MARK: - MFMessageDelegate
    
    //
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)

        if(result == MessageComposeResultSent){
            //The user just sent the sms. This interaction will be added
            
            if let contactID = contact?.contactID,
                number = phoneNumberInUse {
                    
                    let newInteraction = Interaction(interactionDirection: InteractionDirection.OUTBOUND,
                        type: InteractionType.SMS,
                        date: Utility.getCurrentTimeInSeconds(),
                        phoneNumber: number, contactID: contactID)
                    
                    //show progresshud
                    hud.showInView(self.navigationController?.view, animated: true)
                    
                    apiHelper.createInteraction(newInteraction, completionHandler: { success in
                        //TODO: Handle a failure
                        
                        //Reload the data to show the new interaction
                        self.loadData()
                    })
            }
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
