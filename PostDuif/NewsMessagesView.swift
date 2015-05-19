//
//  NewsMessagesView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for all the content inside the newsMessagesViewController


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
    
    /**
    Function for setting title text
    
    :param: text The text to set inside the title
    */
    func setTitleText(text: String){
        self.newsMessageTitle.text = text
    }
    
    /**
    Function for setting background for view
    
    :param: color For background view
    */
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting the background for title
    
    :param: color For background title
    */
    func setTitleBackground(color: String){
        self.newsMessageTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting up the title
    */
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.newsMessageTitle.layer.borderWidth = 1
        self.newsMessageTitle.layer.borderColor = borderColor.CGColor
        self.newsMessageTitle.layer.cornerRadius = 0
    }
    
    /**
    Function for setting text for content
    
    :param: text The text to set inside the content
    */
    func setMessageText(text: String){
        newsMessageContent.setMessageText(text)
    }
    
    /**
    Function for setting background content
    
    :param: color The color for background content
    */
    func setContentBackground(color: String){
        self.newsMessageContent.setContentBackground(color)
    }
    
    /**
    Function for setting the font color for title and content
    
    :param: color The color for setting into the title and content
    */
    func setFontColor(color: String){
        self.newsMessageTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.newsMessageContent.setFontColor(color)
        
    }
    
    /**
    Function for setting the fontsize inside the content
    
    :param: size The size for the content font size
    */
    func setFontSize(size: CGFloat){
        self.newsMessageContent.setFontSize(size)
    }
    
    /**
    Function for setting up the content
    */
    func setupContent(){
        self.newsMessageContent.contentDelegate = self
        self.newsMessageContent.setupContent()
        self.setupSwipingContentTextView() // For contentTextView
    }
    
    
    /**
    Function for setting up the swiping inside the textView
    */
    private func setupSwipingContentTextView(){
        self.newsMessageContent.setupSwiping()
    }
    
    /**
    Function for swiping to close the newsMessage
    */
    func setupSwiping(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    /**
    Selector when swiped left to close the message
    */
    func leftSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }
    
    /**
    Function for swiping when accessibility is enabled
    
    :param: direction The direction when swiping
    */
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        
        return true
    }
}