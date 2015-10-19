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
        self.navigationController?.navigationBarHidden = false
        
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
    
    
    //================================
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    
    /** configure cell*/
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        
        let text = NSMutableAttributedString(string: "")
        let fontSize = CGFloat(18)
        
        let contact = contacts[indexPath.row]
        if let firstname = contact.firstname, lastname = contact.lastname {
            //Stylize text
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
        
        return cell
    }
    
    
    @IBAction func logoutAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        apiHelper.logout()
    }

    /** Handle selection of a cell (a contact), which will display information about the it*/
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showContactDetailsSegue", sender: contacts[indexPath.row])
    }
    
    
    /*
    //================================
    // MARK: - Navigation
    */
    
    /**prepare the next controller*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showContactDetailsSegue"){
            //Pass the selected contact and the list of all contacts to the next controller
            let vc = segue.destinationViewController as! ContactInformationTVC
            vc.contact = sender as? Contact
            vc.allContact = contacts
        }
    }
    
}
