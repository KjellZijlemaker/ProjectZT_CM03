//
//  NewsMessagesContentTextView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-05-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for custom textView inside the newsMessagesView (for swiping inside textView)


import Foundation

class NewsMessagesContentTextView: UITextView{
    
    var contentDelegate: newsMessagesContentTextViewDelegate!
    
    /**
    Function for setting text inside the textView
    
    :param: text The text that will be put inside the textView
    */
    func setMessageText(text: String){
        self.text = text
    }
    
    /**
    Function for setting the background for the content
    
    :param: color The color for the background
    */
    func setContentBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting the color for the font
    
    :param: color The color for the font
    */
    func setFontColor(color: String){
        self.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting the size for the font
    
    :param: size The size for the font
    */
    func setFontSize(size: CGFloat){
        self.font = UIFont(name: "Verdana", size: size)
    }
    
    /**
    Function for setting up the content inside the view
    */
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.CGColor
        self.layer.cornerRadius = 0
    }
    
    /**
    Function for setting the swipe inside the textView
    */
    func setupSwiping(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    /**
    Selector for calling when swiped left
    */
    func leftSwiped(){
        self.contentDelegate.delegate.speech.stopSpeech() //Stop speech
        self.contentDelegate.delegate.dismissController() // Dismiss the controller
    }
    
    /**
    Function when accessibility has been activated. It will check if three fingers will go to the direction
    */
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        
        return true
    }
    
}