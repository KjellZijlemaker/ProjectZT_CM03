//
//  LoginViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 23-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  ViewController for login into the application

import UIKit

class LoginViewController: UIViewController, loginDelegate {
    var notificationSound = SoundManager(resourcePath: "Roekoe", fileType: "m4a") // For the sound
    
    @IBOutlet weak var loginView: LoginView!
    
    var token: Token!
    var settings:Settings!
    var keychain = Keychain(service: "com.visio.postduif")
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.setupView(self.view) // Load the view and give context for putting up the view
        self.startLoginSound()
        self.loginView.delegate = self
        self.loginView.setupDelegates()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    Function for starting the loginSound (ROEKOE)
    */
    func startLoginSound(){
        notificationSound.playSound()
    }
    
    /**
    Function for sending the login request to the server
    
    :param: pincode The pincode that the user has used as input (from LoginView)
    */
    func sendLoginRequest(pincode: String){
        // Making URL
        var url = "http://84.107.107.169:8080/VisioWebApp/API/authentication?username=" + self.loginView.loginEmail.text + "&pincode=" + pincode
        
        // Miking new notification
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
                    
                    // Setting the tokens for getting later in another controller
                    self.defaults.setObject(self.token.getToken(), forKey: "token")
                    self.defaults.setObject(self.token.getRefreshToken(), forKey: "refreshToken")
                    //                    self.keychain.set(self.token.getToken(), key: "token")
                    //                    self.keychain.set(self.token.getRefreshToken(), key: "refreshToken")
                    
                    // For performing the seque inside the storyboard
                    self.performSegueWithIdentifier("loginSucceed", sender: self)
                }
                
            }
            else{
                
                // Make error message
                var error = "Uw toegangscode of gebruikersnaam is onjuist. Probeer het opnieuw!"
                var alert:SIAlertView  = SIAlertView(title: "Fout", andMessage: error)
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
