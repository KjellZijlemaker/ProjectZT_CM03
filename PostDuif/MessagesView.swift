//
//  MessageView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class MessagesView: UIView, messagesContentTextViewDelegate{
    
    @IBOutlet weak private var messageTitle: UITextView!
    @IBOutlet weak var messageContent: MessagesContentTextView!
    
    var delegate: messagesDelegate!
    
    func setTitleText(text: String){
        self.messageTitle.text = text
    }
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setTitleBackground(color: String){
        self.messageTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.messageTitle.layer.borderWidth = 1
        self.messageTitle.layer.borderColor = borderColor.CGColor
        self.messageTitle.layer.cornerRadius = 0
    }

    func setContentBackground(color: String){
        self.messageContent.setContentBackground(color)
    }
    
    func setFontColor(color: String){
        self.messageTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.messageContent.setFontColor(color)
    }
    
    func setMessageText(text: String){
        self.messageContent.setMessageText(text)
    }
    
    func setFontSize(size: CGFloat){
        self.messageContent.setFontSize(size)
    }
    
    func setupContent(){
        self.messageContent.contentDelegate = self
        self.messageContent.setupContent()
        self.setupSwipingContentTextView() // For contentTextView
        
    }
    
    private func setupSwipingContentTextView(){
        self.messageContent.setupSwiping()
    }
    
    
    func setupSwiping(){
        
        //------------right  swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    
    //------------Swipe method to the right--------------//
    func leftSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }
    
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        
        return true
    }
    
    
}

