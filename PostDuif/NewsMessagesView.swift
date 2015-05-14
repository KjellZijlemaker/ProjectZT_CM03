//
//  NewsMessagesView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class NewsMessageView: UIView{
    @IBOutlet weak var newsMessageTitle: UITextView!
    @IBOutlet weak var newsMessageContent: UITextView!

    var delegate: newsMessagesDelegate!
    
    //    @IBAction func normalText(sender: AnyObject) {
    //        self.newsMessageContent.font = UIFont(name: "Verdana", size: 42)
    //    }
    //    @IBAction func bigText(sender: AnyObject) {
    //        self.newsMessageContent.font = UIFont(name: "Verdana", size: 49)
    //    }
    //
    //    @IBAction func biggerText(sender: AnyObject) {
    //        self.newsMessageContent.font = UIFont(name: "Verdana", size: 54)
    //    }

    
    func setTitleText(text: String){
        self.newsMessageTitle.text = text
    }
    
    func setMessageText(text: String){
        self.newsMessageContent.text = text
    }
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setTitleBackground(color: String){
        self.newsMessageTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setContentBackground(color: String){
        self.newsMessageContent.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setFontColor(color: String){
        self.newsMessageTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.newsMessageContent.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setFontSize(size: CGFloat){
        self.newsMessageContent.font = UIFont(name: "Verdana", size: size)
    }
    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.newsMessageTitle.layer.borderWidth = 1
        self.newsMessageTitle.layer.borderColor = borderColor.CGColor
        self.newsMessageTitle.layer.cornerRadius = 0
    }
    
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.newsMessageContent.layer.borderWidth = 1
        self.newsMessageContent.layer.borderColor = borderColor.CGColor
        self.newsMessageContent.layer.cornerRadius = 0
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