//
//  ClubNewsView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for all the content inside the clubNewsViewController

import Foundation

class ClubNewsView: UIView, clubNewsContentTextViewDelegate{
    
    @IBOutlet weak private var clubNewsTitle: UITextView!
    @IBOutlet weak var clubNewsContent: ClubNewsContentTextView!
    var delegate: clubNewsDelegate!
    
    /**
    Function for setting the title
    
    :param: text The text for the title
    */
    func setTitleText(text: String){
        self.clubNewsTitle.text = text
    }
    
    /**
    Function for setting the background for the view
    
    :param: color The color for inside the view as background
    */
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting the background of the title view
    
    :param: color The color for inside the view as background
    */
    func setTitleBackground(color: String){
        self.clubNewsTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting up the title itself
    */
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.clubNewsTitle.layer.borderWidth = 1
        self.clubNewsTitle.layer.borderColor = borderColor.CGColor
        self.clubNewsTitle.layer.cornerRadius = 0
    }
    
    /**
    Function for setting up the swiping for closing the clubnews
    
    :param: color The color for inside the view as background
    */
    func setupSwiping(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    /**
    Function for setting the clubnewsContent
    
    :param: text The text to set inside the content
    */
    func setMessageText(text: String){
        self.clubNewsContent.setMessageText(text)
    }
    
    /**
    Function for setting the background of the clubnewsContent
    
    :param: color The color for the background inside the content view
    */
    func setContentBackground(color: String){
        self.clubNewsContent.setContentBackground(color)
    }
    
    /**
    Function for setting the font color inside the title and content
    
    :param: color The color to be set as fontColor
    */
    func setFontColor(color: String){
        self.clubNewsTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.clubNewsContent.setFontColor(color)
    }
    
    /**
    Function for setting the size of the font inside the clubnewsContent
    
    :param: size The size to be given with the font
    */
    func setFontSize(size: CGFloat){
        self.clubNewsContent.setFontSize(size)
    }
    
    /**
    Function for setting up the clubnewsContent itself
    */
    func setupContent(){
        self.clubNewsContent.contentDelegate = self
        self.clubNewsContent.setupContent()
        self.setupSwipingContentTextView()
    }
    
    /**
    Function for setting the swiping inside the content textview
    */
    private func setupSwipingContentTextView(){
        self.clubNewsContent.setupSwiping()
    }
    
    
    /**
    Function for swiping to the left and close the item
    */
    func leftSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }
    
    /**
    Function for swiping when accessibility is enabled
    
    :param: text The text to set inside the content
    */
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        
        return true
    }
}