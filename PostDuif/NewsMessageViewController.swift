//
//  NewsContentViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 15-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class NewsMessageViewController: UIViewController, newsMessagesDelegate {
    var news:Item!
    var userSettings:Settings!
    var speech:SpeechManager!
    var delegate: newsMessagesDelegate!
    var openendMessage: messageOpenend!
    var deletingMessage: deleteMessageItem!
    var userDelegate: userManagerDelegate!
    
    @IBOutlet var newsMessagesView: NewsMessageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view
        self.newsMessagesView.delegate = self
        self.newsMessagesView.setupTitle()
        self.newsMessagesView.setupContent()
        self.newsMessagesView.setupSwiping()
        
        // Setting the text
        self.newsMessagesView.setTitleText(self.news.getSubject())
        self.newsMessagesView.setMessageText(self.news.getContent())//Putting back the message inside the controller
        
        // Setting the color and backround
        self.newsMessagesView.setFontColor(self.userSettings.getPrimaryColorType())
        self.newsMessagesView.setFontSize(self.userSettings.getFontSize())
        self.newsMessagesView.setViewBackground("000000")
        self.newsMessagesView.setTitleBackground(self.userSettings.getSecondaryColorType())
        self.newsMessagesView.setContentBackground(self.userSettings.getSecondaryColorType())
        
        // Speech the item
        if(!UIAccessibilityIsVoiceOverRunning() && self.userSettings.isSpeechEnabled()){
            var carouselSpeechHelper = CarouselSpeechHelper(speech: self.speech, userSettings: self.userSettings)
            carouselSpeechHelper.speechNewsMessageItem(self.news)
        }
        
    }
    
    /**
    Function for dismissing the controller (called from the NewsMessagesView)
    */
    func dismissController(){
        self.speech.speechString("U heeft het nieuwsbericht gelezen") //Little speech for user
        self.openendMessage.messageIsOpenend = false // NewsMessage is not openend anymore
        self.deletingMessage.deleteMessage(self.news.getID(), "2")
        
        // Dismiss the controller
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    Function for sensing if the user has shaken the device. It will then check for new settings silently
    */
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == .MotionShake) {
            self.userDelegate.getUserSettings(self.userDelegate.token.getToken(), updateSettings: true)
            var carouselSpeechHelper = CarouselSpeechHelper(speech: self.speech, userSettings: self.userSettings)
            
            // Setting the color and backround again
            self.newsMessagesView.setFontColor(self.userSettings.getPrimaryColorType())
            self.newsMessagesView.setViewBackground("000000")
            self.newsMessagesView.setTitleBackground(self.userSettings.getSecondaryColorType())
            self.newsMessagesView.setContentBackground(self.userSettings.getSecondaryColorType())
            
        }
    }
}
