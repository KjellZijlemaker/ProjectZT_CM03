//
//  ClubNewsView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class ClubNewsView: UIView{
    
    @IBOutlet weak private var clubNewsTitle: UITextView!
    @IBOutlet weak private var clubNewsContent: UITextView!
    var delegate: clubNewsDelegate!
    
    func setTitleText(text: String){
        self.clubNewsTitle.text = text
    }
    
    func setMessageText(text: String){
        self.clubNewsContent.text = text
    }
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.clubNewsTitle.layer.borderWidth = 1
        self.clubNewsTitle.layer.borderColor = borderColor.CGColor
        self.clubNewsTitle.layer.cornerRadius = 0
    }
    
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.clubNewsContent.layer.borderWidth = 1
        self.clubNewsContent.layer.borderColor = borderColor.CGColor
        self.clubNewsContent.layer.cornerRadius = 0
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