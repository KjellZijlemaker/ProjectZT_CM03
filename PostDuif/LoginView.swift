//
//  LoginView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 30-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for all the content inside the LoginViewController


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
    
    /**
    Function for saving view context inside the view from controller
    
    :param: view The view from the controller to be saved
    */
    func setupView(view: UIView){
        self.loginView = view
    }
    
    /**
    Function for setting up the delegates for using overridden methods
    
    :param: text The text to set inside the content
    */
    func setupDelegates(){
        self.loginEmail.delegate = self
        self.loginPincode.delegate = self
        self.loginPincode2.delegate = self
    }
    
    /**
    Function for checking if a touch around the view is present. If so, close the keyboard
    */
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    /**
    Function for checking if view is clicked. When clicked, view must go up for keyboard
    
    :param: textField The textField that will be called by the delegate
    */
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
    
    /**
    Function for checking if the clicked view is dismissed. When dismissed, the view should go down again
    
    :param: textField The textField that will be called by the delegate
    */
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
    
    /**
    Function for animating the view going up or down
    
    :param: up Is it going up or down?
    :param: moveValue How much does it needs to go up or down?
    */
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.loginView.frame = CGRectOffset(self.loginView.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    /**
    Function for checking if another view should be the responder, when ticking on the return button
    
    :param: textField The textField that will be called by the delegate
    :returns: Bool Returns boolean for indicating that the textfield has been called
    */
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
    
    /**
    Function for checking the pincode. It should automatically go to the next pincode view when at the end of the first. Also, when going back, the view should automatically call the previous view
    
    :param: textField The textField that will be called by the delegate
    :param: range The range in whitch the observer should change the characters
    :param: replacementString The String that will be the replaced String for the View
    :returns: Bool Returns Boolean for indicating that the textfield has been called
    */
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