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
        
        if(!UIAccessibilityIsVoiceOverRunning() && self.userSettings.isSpeechEnabled()){
            var speechClubNewsItem = CarouselSpeechHelper(speech: self.speech)
            
            // Speech the item
            speechClubNewsItem.speechClubNewsItem(self.clubNews)
        }

    }

    
    // Dismiss the controller
    func dismissController(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            self.speech.speechString("U heeft het club, of organisatiebericht gelezen") //Little speech for user
            self.openendMessage.messageIsOpenend = false
            self.deletingMessage.executeDeletionTimer(self.clubNews.getID(), "3")
        });
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Motion gesture
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == .MotionShake) {
            self.userDelegate.getUserSettings(self.userDelegate.token.getToken(), updateSettings: true)
            if(self.userSettings.isNotificationSoundEnabled()){
                var carouselSpeechHelper = CarouselSpeechHelper()
                
                // Setting the color and backround again
                self.clubNewsView.setFontColor(self.userSettings.getPrimaryColorType())
                self.clubNewsView.setViewBackground("000000")
                self.clubNewsView.setTitleBackground(self.userSettings.getSecondaryColorType())
                self.clubNewsView.setContentBackground(self.userSettings.getSecondaryColorType())
                
                carouselSpeechHelper.getSpeech().speechString("Instellingen bijgewerkt")
            }
        }
    }
}
