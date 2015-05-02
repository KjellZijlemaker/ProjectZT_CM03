//
//  MessageView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class MessagesView: UIView{
    
    @IBOutlet weak private var messageTitle: UITextView!
    @IBOutlet weak private var messageContent: UITextView!
    
    var delegate: messagesDelegate!
    
    func setTitleText(text: String){
        self.messageTitle.text = text
    }
    
    func setMessageText(text: String){
        self.messageContent.text = text
    }
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.messageTitle.layer.borderWidth = 1
        self.messageTitle.layer.borderColor = borderColor.CGColor
        self.messageTitle.layer.cornerRadius = 0
    }
    
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.messageContent.layer.borderWidth = 1
        self.messageContent.layer.borderColor = borderColor.CGColor
        self.messageContent.layer.cornerRadius = 0
    }
    
    func setupSwiping(){
        //------------right  swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        swipeLeft.isAccessibilityElement = true
        if(isAccessibilityElement){
            swipeLeft.numberOfTouchesRequired = 3
        }
        self.addGestureRecognizer(swipeLeft)
    }
    
    
    //------------Swipe method to the right--------------//
    func leftSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }

}

