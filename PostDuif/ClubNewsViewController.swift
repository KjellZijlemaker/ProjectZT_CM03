//
//  ClubNewsViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 22-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class ClubNewsViewController: UIViewController {

    @IBOutlet weak var clubNewsTitle: UITextView!
    @IBOutlet weak var clubNewsContent: UITextView!
    
    var clubNews:Item!
    var userSettings:Settings!
    var speech:SpeechManager = SpeechManager()
    var delegate: deleteMessageItem!
    var openendMessage: messageOpenend!
    var deletingMessage: deleteMessageItem!
    var carouselID: String!
    var speechEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var borderColor : UIColor = UIColor.grayColor()
        self.clubNewsTitle.layer.borderWidth = 1
        self.clubNewsTitle.layer.borderColor = borderColor.CGColor
        self.clubNewsTitle.layer.cornerRadius = 0
        self.clubNewsContent.layer.borderWidth = 1
        self.clubNewsContent.layer.borderColor = borderColor.CGColor
        self.clubNewsContent.layer.cornerRadius = 0
        
        //self.newsMessageTitle.layer.cornerRadius = 8
        self.clubNewsTitle.text = self.clubNews.getSubject()
        
        // self.newsMessageText.layer.cornerRadius = 8
        self.clubNewsContent.text = self.clubNews.getContent() //Putting back the message inside the controller
        
        if(self.speechEnabled){
            
            // Making new sentence array for speech
            var sentenceArray: [String] = []
            sentenceArray.append("Titel nieuwsbrief: " + self.clubNews.getSubject())
            sentenceArray.append("Inhoud nieuwsbrief: ")
            sentenceArray.append(self.clubNewsContent.text)
            sentenceArray.append("Einde nieuwsbrief")
            sentenceArray.append("Veeg naar rechts om het nieuwsbrief te sluiten")
            
            self.speech.speechArray(sentenceArray) //Execute speech
        }
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        self.speech.stopSpeech() //Stop speech
        
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            if(self.speechEnabled){
                self.speech.speechString("U heeft de nieuwsbrief gelezen") //Little speech for user
            }
            self.delegate.executeDeletionTimer(self.carouselID, "3")
        });
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
