//
//  LoginViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 23-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var loginEmail: UITextField!
    
    @IBOutlet weak var loginPincode1: UITextField!
    @IBOutlet weak var loginPincode2: UITextField!
    @IBOutlet weak var loginPincode3: UITextField!
    var token: Token!
    var keychain = Keychain(service: "com.visio.postduif")
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For putting the view up when having keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Functions for putting view to top
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 200
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 200
    }
    
    func rightSwiped(){
        
        // Making pincode
        var pincode = self.loginPincode1.text + "-" + self.loginPincode2.text + "-" + self.loginPincode3.text
        
        // Making URL
        var url = "http://84.107.107.169:8080/VisioWebApp/API/authentication?username=" + self.loginEmail.text + "&pincode=" + pincode
        
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Bezig met inloggen"
        
        
        // Sending URL and logging in
        UserManager.loginUser(url){(token) in
            
            self.token = token // Set token inside global token
            
            // Check if token has been made and fire segue
            if(token.getReturnCode() == "200"){
                if(token.getStatus() == "success"){
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    
                    self.defaults.setObject(self.token.getToken(), forKey: "token")
                    self.defaults.setObject(self.token.getRefreshToken(), forKey: "refreshToken")
//                    self.keychain.set(self.token.getToken(), key: "token")
//                    self.keychain.set(self.token.getRefreshToken(), key: "refreshToken")

                    // For performing the seque inside the storyboard
                    self.performSegueWithIdentifier("loginSucceed", sender: self)
                }
                
            }
            else{
                var alert:SIAlertView  = SIAlertView(title: "Fout", andMessage: token.getMessage())
                alert.titleFont = UIFont(name: "Verdana", size: 30)
                alert.messageFont = UIFont(name: "Verdana", size: 26)
                alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler: nil)
                alert.buttonFont = UIFont(name: "Verdana", size: 30)
                alert.transitionStyle = SIAlertViewTransitionStyle.Bounce
                
                alert.show()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    // Segue methods
    //=================================================================================================
    // Preparing the seque and send data with ViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        self.loginEmail.text = ""
        self.loginPincode1.text = ""
        self.loginPincode2.text = ""
        self.loginPincode3.text = ""
        if segue.identifier == "loginSucceed"{            
            let vc = segue.destinationViewController as ViewController
            //vc.keychain = self.keychain // Sending keyChain
        }
        
    }

}
