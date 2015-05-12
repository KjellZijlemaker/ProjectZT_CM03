//
//  ContentView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class MessageContentViewController: UIViewController, messagesDelegate {
    var message:Item!
    var userSettings:Settings!
    var speech:SpeechManager!
    var deletingMessage: deleteMessageItem!
    var delegate: messagesDelegate!
    var openendMessage: messageOpenend!
    var userDelegate: userManagerDelegate!
    
    @IBOutlet var messagesView: MessagesView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view
        self.messagesView.delegate = self
        self.messagesView.setupTitle()
        self.messagesView.setupContent()
        self.messagesView.setupSwiping()
    
        // Setting the text
        self.messagesView.setTitleText(self.message.getSubject())
        self.messagesView.setMessageText(self.message.getContent())//Putting back the message inside the controller
        
        // Setting the color and backround
        self.messagesView.setFontColor(self.userSettings.getPrimaryColorType())
        self.messagesView.setViewBackground("000000")
        self.messagesView.setTitleBackground(self.userSettings.getSecondaryColorType())
        self.messagesView.setContentBackground(self.userSettings.getSecondaryColorType())
        
        if(!UIAccessibilityIsVoiceOverRunning() && self.delegate.userSettings.isSpeechEnabled()){
            var carouselSpeechHelper = CarouselSpeechHelper()
            carouselSpeechHelper.speechMessageItem(self.message)
        }
    }

    
    func dismissController(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            self.speech.speechString("U heeft het bericht gelezen") //Little speech for user
            self.openendMessage.messageIsOpenend = false
            self.deletingMessage.executeDeletionTimer(self.message.getID(), "1")
        });
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
                self.messagesView.setFontColor(self.userSettings.getPrimaryColorType())
                self.messagesView.setViewBackground("000000")
                self.messagesView.setTitleBackground(self.userSettings.getSecondaryColorType())
                self.messagesView.setContentBackground(self.userSettings.getSecondaryColorType())
                
                carouselSpeechHelper.getSpeech().speechString("Instellingen bijgewerkt")
            }
        }
    }
    
}
