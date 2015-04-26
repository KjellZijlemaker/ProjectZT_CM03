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
    
    func setTitleText(text: String){
        self.newsMessageTitle.text = text
    }
    
    func setMessageText(text: String){
        self.newsMessageContent.text = text
    }
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
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
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.addGestureRecognizer(swipeRight)
    }
    
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }

    
    
}