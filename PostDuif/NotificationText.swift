//
//  NotificationText.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class NotificationText: UITextField{
    
    private var txtField: UITextField!
    
    // For drawing custom textField
    override func drawRect(rect: CGRect) {
        
    }
    
    func makeNotificationTextView(){
        
        // Making textfield for new items
        self.txtField = UITextField(frame: CGRect(x: 43, y: 130, width: 15.00, height: 30.00));
        self.txtField.hidden = true
        self.txtField.borderStyle = UITextBorderStyle.Line
        self.txtField.backgroundColor = UIColor.yellowColor()
        self.txtField.userInteractionEnabled = false
        self.txtField.borderStyle = UITextBorderStyle.None
    }
    
    func showNotificationTextView(){
       self.txtField.hidden = false
    }
    
    func hideNotificationTextView(){
        self.txtField.hidden = true
    }
    
    func setNotificationTextView(text: String){
        self.txtField.text = text
    }
    
    func removeNotificationTextFromView(){
        self.txtField.removeFromSuperview()
    }
    
    func getNotificationTextView() -> UITextField{
        return self.txtField
    }
    
}