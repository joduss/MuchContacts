//
//  InteractionsTVC.swift
//  MuchContacts
//
//  Created by Jonathan on 19/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit
import JGProgressHUD

class InteractionsTVC: ContactsTVC {

    private var interactions = Array<Interaction>()
    private var loading = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //autosize cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        self.tableView.allowsSelection = false
        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Download the data from the server
    override func loadData() {
        super.loadData()
        //hud.showInView(self.navigationController?.view, animated: true)
        loading++
        
        apiHelper.getAllInteraction( {downloadedInteractions in
            self.interactions = downloadedInteractions
            self.tableView.reloadData()
            self.loading--
            if(self.loading == 0) {
                self.hud.dismissAnimated(true)
            }
        })

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return interactions.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        return prepareCellForSection1ForInteraction(tableView, forIndexPath: indexPath)
        
        return UITableViewCell()
    }
    
    
    /**Setup the cell for an Interaction*/
    func prepareCellForSection1ForInteraction(tv : UITableView, forIndexPath indexPath: NSIndexPath) -> UITableViewCell{
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
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //do nothing
    }
    
    
    /**Find the contact corresponding to the specified contact id*/
    func findContactWithID(contactID : String) -> Contact? {
        for c in contacts {
            if(c.contactID == contactID){
                return c
            }
        }
        return nil
    }
    
    
}
