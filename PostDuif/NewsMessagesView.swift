//
//  NewsMessagesView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class NewsMessageView: UIView, newsMessagesContentTextViewDelegate{
    @IBOutlet weak var newsMessageTitle: UITextView!
    @IBOutlet weak var newsMessageContent: NewsMessagesContentTextView!

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
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setTitleBackground(color: String){
        self.newsMessageTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    

    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.newsMessageTitle.layer.borderWidth = 1
        self.newsMessageTitle.layer.borderColor = borderColor.CGColor
        self.newsMessageTitle.layer.cornerRadius = 0
    }
    
    func setMessageText(text: String){
        newsMessageContent.setMessageText(text)
    }
    
    func setContentBackground(color: String){
        self.newsMessageContent.setContentBackground(color)
    }
    
    func setFontColor(color: String){
        self.newsMessageTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.newsMessageContent.setFontColor(color)

    }
    
    func setFontSize(size: CGFloat){
        self.newsMessageContent.setFontSize(size)
    }
    
    func setupContent(){
        self.newsMessageContent.contentDelegate = self
        self.newsMessageContent.setupContent()
        self.setupSwipingContentTextView() // For contentTextView
    }
    
    
    private func setupSwipingContentTextView(){
        self.newsMessageContent.setupSwiping()
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