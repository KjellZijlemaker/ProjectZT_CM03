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
    var delegate: deleteMessageItem!
    var openendMessage: messageOpenend!
    var deletingMessage: deleteMessageItem!
    
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
        if(self.userSettings.getColorType() != "default"){
            self.clubNewsView.setViewBackground(self.userSettings.getColorType())
        }
        if(self.userSettings.getContrastType() != "default"){
            
        }
        
        if(self.userSettings.isSpeechEnabled()){
            // Speech the item
            self.speechClubNewsItem()
        }

    }

    // Speech the item
    func speechClubNewsItem(){
        
            // Making new sentence array for speech
            var sentenceArray: [String] = []
            sentenceArray.append("Titel nieuwsbrief: " + self.clubNews.getSubject())
            sentenceArray.append("Inhoud nieuwsbrief: ")
            sentenceArray.append(self.clubNews.getContent())
            sentenceArray.append("Einde nieuwsbrief")
            sentenceArray.append("Veeg naar rechts om het nieuwsbrief te sluiten")
            
            self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    // Dismiss the controller
    func dismissController(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            if(self.userSettings.isSpeechEnabled()){
                self.speech.speechString("U heeft de nieuwsbrief gelezen") //Little speech for user
            }
            self.delegate.executeDeletionTimer(self.clubNews.getID(), "3")
        });
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
