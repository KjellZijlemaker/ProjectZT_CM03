//
//  LoginViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 23-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, loginDelegate {

    @IBOutlet weak var loginView: LoginView!
    
    var token: Token!
    var settings:Settings!
    var keychain = Keychain(service: "com.visio.postduif")
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.delegate = self
        self.loginView.setupListeners()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func sendLoginRequest(pincode: String){
        // Making URL
        var url = "http://84.107.107.169:8080/VisioWebApp/API/authentication?username=" + self.loginView.loginEmail.text + "&pincode=" + pincode
        
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
        self.loginView.loginEmail.text = ""
        self.loginView.loginPincode.text = ""
        if segue.identifier == "loginSucceed"{            
            let vc = segue.destinationViewController as ViewController
            //vc.keychain = self.keychain // Sending keyChain
        }
        
    }

}
