//
//  ContactsTVC.swift
//  MuchContacts
//
//  Created by Jonathan on 17/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit
import JGProgressHUD

class ContactsTVC: UITableViewController {
    
    var contacts = Array<Contact>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView.init(HUDStyle: hud.style)
        hud.showInView(self.navigationController?.view, animated: true)
        
        apiHelper.getAllContacts(0, completionHandler: {contacts in
            self.contacts = contacts
            self.tableView.reloadData()
            hud.dismissAnimated(true)
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        
        let text = NSMutableAttributedString(string: "")
        let fontSize = CGFloat(18)
        
        let contact = contacts[indexPath.row]
        if let firstname = contact.firstname, lastname = contact.lastname {
            text.appendAttributedString(NSMutableAttributedString(string: " " + firstname, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(fontSize)]))
            text.appendAttributedString(NSMutableAttributedString(string: " " + lastname, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(fontSize)]))
        }
        else {
            //If firstname and lastname are nil, it's likely a company
            if let companyName = contact.companyName {
                text.appendAttributedString(NSMutableAttributedString(string: companyName, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(fontSize)]))
            }
            else {
                text.appendAttributedString(NSMutableAttributedString(string:"unknown [null]"))
            }
        }
        
        cell.textLabel?.attributedText = text
        // Configure the cell...
        
        return cell
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
