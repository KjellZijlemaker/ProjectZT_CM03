//
//  ClubNewsViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 22-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class ClubNewsViewController: UIViewController, clubNewsDelegate {
    @IBOutlet var clubNewsView: ClubNewsView!
    
    var clubNews:Item!
    var userSettings:Settings!
    var speech:SpeechManager!
    var delegate: clubNewsDelegate!
    var openendMessage: messageOpenend!
    var deletingMessage: deleteMessageItem!
    var userDelegate: userManagerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the view
        self.clubNewsView.delegate = self
        self.clubNewsView.setupTitle()
        self.clubNewsView.setupContent()
        self.clubNewsView.setupSwiping()
        
        // Setting the text
        self.clubNewsView.setTitleText(self.clubNews.getSubject())
        self.clubNewsView.setMessageText(self.clubNews.getContent())//Putting back the message inside the controller
        
        // Setting the color and backround
        self.clubNewsView.setFontColor(self.userSettings.getPrimaryColorType())
        self.clubNewsView.setViewBackground("000000")
        self.clubNewsView.setTitleBackground(self.userSettings.getSecondaryColorType())
        self.clubNewsView.setContentBackground(self.userSettings.getSecondaryColorType())
        
        // Speech the item
        if(!UIAccessibilityIsVoiceOverRunning() && self.userSettings.isSpeechEnabled()){
            var speechClubNewsItem = CarouselSpeechHelper(speech: self.speech, userSettings: self.userSettings)
            speechClubNewsItem.speechClubNewsItem(self.clubNews)
        }
        
    }
    
    
    /**
    Function for dismissing the controller (called from the ClubNewsView)
    */
    func dismissController(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            self.speech.speechString("U heeft het " + self.clubNews.getClubType() + "-bericht gelezen") //Little speech for user
            self.openendMessage.messageIsOpenend = false // ClubNews is not openend anymore
            self.deletingMessage.deleteMessage(self.clubNews.getID(), "3") // Delete the message
        });
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
            self.clubNewsView.setFontColor(self.userSettings.getPrimaryColorType())
            self.clubNewsView.setViewBackground("000000")
            self.clubNewsView.setTitleBackground(self.userSettings.getSecondaryColorType())
            self.clubNewsView.setContentBackground(self.userSettings.getSecondaryColorType())
            
        }
    }
}
