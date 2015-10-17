//
//  ViewController.swift
//  Friendly
//
//  Created by Jonathan on 16/10/15.
//  Copyright © 2015 ZaJo. All rights reserved.
//

import UIKit
import JGProgressHUD

class ViewController: UIViewController {
    
    let segueIdentifierAfterLogin = "afterLoginSegue"

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginClicked(sender: UIButton) {
        
        let progress = JGProgressHUD(style: JGProgressHUDStyle.ExtraLight)
        progress.textLabel.text = "Loging in"
        progress.indicatorView = JGProgressHUDIndeterminateIndicatorView.init(HUDStyle: progress.style)
        
        
        
        guard let username = usernameTF.text,
            pwd = passwordTF.text
            where username != "" && pwd != ""
            else{
                self.showAlert(title: "No credential", message: "Please enter your credentials.")
                return
        }
        
        progress.showInView(self.view, animated: true)



        
        apiHelper.login(username: username,
            password: pwd, completion: {(loggedIn, wrongCredentials) in
                progress.dismissAnimated(true)

                if(loggedIn) {
                    self.performSegueWithIdentifier(self.segueIdentifierAfterLogin, sender: nil)
                }
                else if(wrongCredentials == true ) {
                    self.showAlert(title: "Wrong credentials", message: "Please check your username and your password.")
                }
                else {
                    self.showAlert(title: "Error", message: "Another error happened. Most likely due to the network")
                }
        })
        
    }
    
    func showAlert(title title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

