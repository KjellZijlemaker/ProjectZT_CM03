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
        
        // Setting the text
        self.messagesView.setTitleText(self.message.getSubject())
        self.messagesView.setMessageText(self.message.getContent())//Putting back the message inside the controller
        
        // Setting the color and backround
        self.messagesView.setFontColor(self.userSettings.getPrimaryColorType())
        self.messagesView.setFontSize(self.userSettings.getFontSize())
        self.messagesView.setViewBackground("000000")
        self.messagesView.setTitleBackground(self.userSettings.getSecondaryColorType())
        self.messagesView.setContentBackground(self.userSettings.getSecondaryColorType())
        
        // Setting up the picture and swiping
        self.messagesView.setupPicture(self.message.getAttachment(), attachmentDescription: self.message.getAttachmentDescription())
        self.messagesView.setupSwiping()
        
        // speech the item
        if(!UIAccessibilityIsVoiceOverRunning() && self.userSettings.isSpeechEnabled()){
            var carouselSpeechHelper = CarouselSpeechHelper(speech: self.speech, userSettings: self.userSettings)
            carouselSpeechHelper.speechMessageItem(self.message)
        }
    }

    /**
    Function for dismissing the controller (called from the MessagesView)
    */
    func dismissController(){
        
        self.speech.speechString("U heeft het bericht gelezen") //Little speech for user
        self.openendMessage.messageIsOpenend = false // Message is not openend anymore
        self.deletingMessage.deleteMessage(self.message.getID(), "1") // Delete the message
               
        // Dismiss the controller
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
            
            // Setting the color and backround again
            self.messagesView.setFontColor(self.userSettings.getPrimaryColorType())
            self.messagesView.setViewBackground("000000")
            self.messagesView.setTitleBackground(self.userSettings.getSecondaryColorType())
            self.messagesView.setContentBackground(self.userSettings.getSecondaryColorType())
            
        }
    }
}
