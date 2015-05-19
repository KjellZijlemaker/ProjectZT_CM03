//
//  NotificationText.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for the notification text inside the bubble

import Foundation

class NotificationText: UITextField{
    private var txtField: UITextField!
    
    // For drawing custom textField
    override func drawRect(rect: CGRect) {
        
    }
    
    /**
    Function for making the notification textView
    */
    func makeNotificationTextView(){
        
        // Making textfield for new items
        self.txtField = UITextField(frame: CGRect(x: 43, y: 130, width: 15.00, height: 30.00));
        self.txtField.hidden = true
        self.txtField.borderStyle = UITextBorderStyle.Line
        self.txtField.backgroundColor = UIColor.yellowColor()
        self.txtField.userInteractionEnabled = false
        self.txtField.borderStyle = UITextBorderStyle.None
    }
    
    /**
    Show the notification
    */
    func showNotificationTextView(){
        self.txtField.hidden = false
    }
    
    /**
    Hide the notification
    */
    func hideNotificationTextView(){
        self.txtField.hidden = true
    }
    
    /**
    Function for setting the notficiationText
    
    :param: text The text to be inserting inside the notification
    */
    func setNotificationTextView(text: String){
        self.txtField.text = text
    }
    
    
    /**
    Function for removing the notificationText from the view
    */
    func removeNotificationTextFromView(){
        self.txtField.removeFromSuperview()
    }
    
    
    /**
    Function getting the textField for adding to view
    
    :returns: UITextField The textField for adding to view
    */
    func getNotificationTextView() -> UITextField{
        return self.txtField
    }
    
}