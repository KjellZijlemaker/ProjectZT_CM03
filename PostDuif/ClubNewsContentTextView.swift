//
//  ClubNewsContentTextView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-05-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class ClubNewsContentTextView: UITextView{
    
    var contentDelegate: clubNewsContentTextViewDelegate!
    
    func setMessageText(text: String){
        self.text = text
    }
    
    func setContentBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setFontColor(color: String){
        self.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setFontSize(size: CGFloat){
        self.font = UIFont(name: "Verdana", size: size)
    }
    
    
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.CGColor
        self.layer.cornerRadius = 0
    }
    
    
    func setupSwiping(){
        //------------right  swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    //------------Swipe method to the right--------------//
    func leftSwiped(){
        self.contentDelegate.delegate.speech.stopSpeech() //Stop speech
        self.contentDelegate.delegate.dismissController() // Dismiss the controller
    }
    
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        
        return true
    }
    
}