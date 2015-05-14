//
//  ClubNewsView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class ClubNewsView: UIView, clubNewsContentTextViewDelegate{
    
    @IBOutlet weak private var clubNewsTitle: UITextView!
    @IBOutlet weak var clubNewsContent: ClubNewsContentTextView!
    var delegate: clubNewsDelegate!
    
    func setTitleText(text: String){
        self.clubNewsTitle.text = text
    }
    

    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setTitleBackground(color: String){
        self.clubNewsTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    

    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.clubNewsTitle.layer.borderWidth = 1
        self.clubNewsTitle.layer.borderColor = borderColor.CGColor
        self.clubNewsTitle.layer.cornerRadius = 0
    }
    
    
    func setupSwiping(){
        //------------right  swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    func setMessageText(text: String){
        self.clubNewsContent.setMessageText(text)
    }
    
    func setContentBackground(color: String){
        self.clubNewsContent.setContentBackground(color)
    }
    
    func setFontColor(color: String){
        self.clubNewsTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.clubNewsContent.setFontColor(color)
    }
    
    func setFontSize(size: CGFloat){
        self.clubNewsContent.setFontSize(size)
    }
    
    func setupContent(){
        self.clubNewsContent.contentDelegate = self
        self.clubNewsContent.setupContent()
        self.setupSwipingContentTextView()
    }
    
    private func setupSwipingContentTextView(){
        self.clubNewsContent.setupSwiping()
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