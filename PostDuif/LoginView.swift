//
//  LoginView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 30-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class LoginView: UIView, UITextViewDelegate{
    private var loginView: UIView!
    
    @IBOutlet weak var loginEmail: UITextView!
    @IBOutlet weak var loginPincode: UITextView!
    @IBOutlet weak var loginPincode2: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButton(sender: AnyObject) {
        
        // Making pincode
        var pincode = self.loginPincode.text + "-" + self.loginPincode2.text
        self.delegate.sendLoginRequest(pincode)
    }
    var delegate: loginDelegate!
    
    // Save view context inside viewcontroller
    func setupView(view: UIView){
        self.loginView = view
    }
    
    func setupListeners(){
        self.loginEmail.delegate = self
        self.loginPincode.delegate = self
        self.loginPincode2.delegate = self
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    // For checking if view is clicked, view must go up for keyboard
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == loginEmail){
            animateViewMoving(true, moveValue: 100)
        }
        else if(textField == loginPincode){
            animateViewMoving(true, moveValue: 200)

        }
        else if(textField == loginPincode2){
            animateViewMoving(true, moveValue: 200)
        }
        
    }
    
    // For checking if view is clicked, view must go up for keyboard
    func textFieldDidEndEditing(textField: UITextField) {
        if(textField == loginEmail){
            animateViewMoving(false, moveValue: 100)
        }
        else if(textField == loginPincode){
            animateViewMoving(false, moveValue: 200)
        }
        else if(textField == loginPincode2){
            animateViewMoving(false, moveValue: 200)
        }
    }
    
    // Put view to the top, or down
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.loginView.frame = CGRectOffset(self.loginView.frame, 0,  movement)
        UIView.commitAnimations()
    }

    // When ticking return button, the other view is activated
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.loginEmail {
            self.loginPincode.becomeFirstResponder()
        }
        if(textField == self.loginPincode){
            self.loginPincode2.becomeFirstResponder()
        }
        if(textField == self.loginPincode2){
            self.loginPincode2.resignFirstResponder()
        }
        return true
    }
    
    // Function for checking the pincode String
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        
        var txtAfterUpdate:NSString = textField.text // Setting the initial text
        
        // Take the initial String for replacement
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        var txtAfterUpdateLength = txtAfterUpdate.length // Getting length
        
        if(textField == loginPincode){
            
            // If the text is at the ending, go to next field
            if(txtAfterUpdateLength > 3){
                loginPincode.resignFirstResponder()
                loginPincode2.becomeFirstResponder()
                return false
            }
            
        }
            
        else if(textField == loginPincode2){
            
            // If it's at the first character, go to previous UITextField
            if (txtAfterUpdateLength <= 0) {
                loginPincode2.text = "" // Set it to empty
                loginPincode.becomeFirstResponder()
                loginPincode2.resignFirstResponder()
                return false;
                
            } else {
                // If the text is at the ending, go to next field
                if(txtAfterUpdateLength > 3){
                    loginPincode2.resignFirstResponder()
                    return false
                }
            }
        }
        
        return true
    }
    
}