//
//  ContactInformationTVC.swift
//  MuchContacts
//
//  Created by Jonathan on 18/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit

class ContactInformationTVC: UITableViewController {
    
    var contact : Contact? {
        didSet {
            apiHelper.getAllInteractionWithContact(contact!, completionHandler: {interactions in
                self.interactions = interactions
                self.tableView.reloadData()
            })
        }
    }
    var allContact = Array<Contact>()
    
    private var interactions = Array<Interaction>()
    
    private var callStartTime = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
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
    
    
    /**Prepare a cell for the section 1*/
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
            labelFirstname.text = contact?.firstname
            labelLastname.text = contact?.lastname
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
            dateLabel.text = date.description;
            
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
        
        if let c = contact where indexPath.section == 0 {
            if(indexPath.row >= 1 && indexPath.row < 1 + c.emails.count) {
                //is an email
            } else if indexPath.row >= 1 + c.emails.count && indexPath.row <= 1 + c.emails.count + c.phones.count {
                //this is making a call
                UIApplication.sharedApplication().openURL(NSURL(string: "tel:\(c.phones[indexPath.row - (1 + c.emails.count)].number)")!)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("callEnded"), name: "CALL", object: nil)
                
                
                callStartTime = Utility.getCurrentTimeMilis()
            }
        }
    }
    
    func callEnded() {
        let callStopTime = Utility.getCurrentTimeMilis()
        let duration = callStopTime - callStartTime
    
        let minutes = Int(duration / Double(1000 * 60))
        let seconds = duration / 1000.0 - Double(minutes)*60.0
        
        print("duration: \(minutes):\(seconds)")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "CALL", object: nil)

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
