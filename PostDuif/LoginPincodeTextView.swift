//
//  LoginPincodeTextView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 19-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class LoginPincodeTextView: UITextField{
    var view: UIView!
    
    func setKeyboardOptions(view: UIView){
        self.view = view
        // For putting the view up when having keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    // Functions for putting view to top
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 120
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 120
    }
    
    func addText(text: String){
        self.text = self.text + text
    }
}