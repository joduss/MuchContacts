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
    
    private(set) var contacts = Array<Contact>()
    var loadingBlocks = 0
    let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView.init(HUDStyle: hud.style)

        self.loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Download the data from the server
    func loadData() {
        hud.showInView(self.navigationController?.view, animated: true)
        loadingBlocks++
        
        apiHelper.getAllContacts(0, completionHandler: {contacts in
            self.contacts = contacts
            self.tableView.reloadData()
            self.loadingBlocks--
            if(self.loadingBlocks == 0){
                self.hud.dismissAnimated(true)
            }
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
    
    /** Handle selection of a cell (a contact), which will display information about the it*/
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showContactDetailsSegue", sender: contacts[indexPath.row])
    }
    
    
    
    
    // MARK: - IBACTION
    @IBAction func logoutAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        apiHelper.logout()
    }

    @IBAction func refresh(sender: AnyObject) {
        self.loadData()
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
