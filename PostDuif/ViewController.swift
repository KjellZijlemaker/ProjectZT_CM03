
//
//  ViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate
{
    // Array for all the items to be loaded inside the carousel
    var items: [Message] = []
    var userSettings: [Settings] = []
    var pictures: [UIImage!] = []
    
    // Setup new synthesizer
    var speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    // For passing on to the other ViewControllers
    var currentIndex: Int = 0
    @IBOutlet var carousel : iCarousel!
    @IBOutlet weak var categoryMessage: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // URL for the JSON
        //var url = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=2/json"
        
        // Getting UserID
        var userID = ""
        
        // Getting the settings by UserID
        getUserSettings(userID)
        
        // Getting the app data and fill it in the global array
        getAppData()
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setting inital settings for swipe gestures
        carousel.userInteractionEnabled = true
        carousel.delegate = self
        carousel.type = .Custom
        carousel.scrollEnabled = false
        
        
        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        //-----------left swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        let dubbleTap = UITapGestureRecognizer(target: self, action: ("dubbleTapped"))
        dubbleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(dubbleTap)
        
    }
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        carousel.scrollByNumberOfItems(-1, duration: 0.25)
        
    }
    
    //------------Swipe method to the left--------------//
    func leftSwiped(){
        carousel.scrollByNumberOfItems(1, duration: 0.25)
    }
    
    //------------Dubble tap method for opening new view--------------//
    func dubbleTapped(){
        
        // Getting the current index of the carousel
        currentIndex = carousel.currentItemIndex
        
        
        switch self.items[currentIndex].getCategory(){
        case "message ":
            // For performing the seque inside the storyboard
            performSegueWithIdentifier("showMessageContent", sender: self)
            println("message")
        case "news":
            performSegueWithIdentifier("showNewsMessageContent", sender: self)
            println("news")
        default:
            // For performing the seque inside the storyboard
            performSegueWithIdentifier("showMessageContent", sender: self)
        }
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return items.count
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
    {
        var label: UILabel! = nil
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            view = UIImageView(frame:CGRectMake(0, 0, 200, 200))
            view.contentMode = .Center
            
            label = UILabel(frame:view.bounds)
            //label.frame = CGRectMake(-140, -150, 500, 100);
            label.frame = CGRectMake(-140, -200, 500, 100);
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(50)
            label.tag = 1
            label.layoutIfNeeded()
            
            // view.addSubview(imageViewObject)
            view.addSubview(label)
        }
        else
        {
            //get a reference to the label in the recycled view
            label = view.viewWithTag(1) as UILabel!
        }
        
        /*
        Checking the index with the current index. If so, content will reload into the View and speech
        will be indexed
        */
        if (index == self.carousel.currentItemIndex) {
            setCategory(index)
            
            //TODO: Check JSON if user has speech in his settings
            speechView(speechSynthesizer, speech: "Begin bericht")
            speechView(speechSynthesizer, speech: "Onderwerp: " + self.items[index].getName())
            speechView(speechSynthesizer, speech: "Inhoud bericht: " + self.items[index].getWebsite())
            speechView(speechSynthesizer, speech: "Einde bericht")
        }
        
        
        
        // Checking for every item
        for i in 0...self.items.count-1{
            // Setting the right images for each category
            setImages(i)
        }
        
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(self.items[index].getName())"
        
        (view as UIImageView!).image = self.pictures[index]
        
        return view
    }
    
    
//    override func viewWillDisappear(animated: Bool) {
//        var oldItems: [Message] = self.items
//        
//        // URL for the JSON
//        var url = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=3/json"
//        
//        // Getting the app data and fill it in the global array
//        getAppData(url)
//        
//        println(oldItems)
//        println(items)
//        
//        for i in 0...items.count-1{
//            if(oldItems[i].getName() != items[i].getName()){
//                println("Dat is een nieuwe!")
//            }
//        }
//
//    }

    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.9
        }
        return value
    }
    
    // Preparing the seque and send data with it
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showMessages"{
            let vc = segue.destinationViewController as MessageContentViewController
            vc.colorString = String(currentIndex)
        }
    }
    
    // Function for getting the main app data and filling it into the array
    func getAppData(){
        
        var url = "http://84.107.107.169:8080/VisioWebApp/notificationTest"
        
        DataManager.getMessages(url){(messages) in
            
            // Transfering array to global array
            self.items = messages
            
            // Iterate through all possible values
            for r in 0...self.items.count-1{
                self.carousel.insertItemAtIndex(r, animated: true)
                println(self.items[r].getName())
            }
        }
        
    }
    
    
    // Function for getting the main app data and filling it into the array
    func getUserSettings(userID: String){
        
        var url = "http://84.107.107.169:8080/VisioWebApp/notificationTest"
        
        DataManager.getUserSettings(url){(settings) in
            
            // Transfering array to global array
            self.userSettings = settings
            
        }
        
    }
    
    // Function for setting the images per category
    func setImages(index: Int){
        
        switch(items[index].getName()){
            case "Clash of Clans":
            pictures.append(UIImage(named:"message.jpg"))
            
            case "Game of War - Fire Age":
             pictures.append(UIImage(named:"news.jpg"))
            
        default:
             pictures.append(UIImage(named:"message.jpg"))
            
        }
        
    }
    
    // Setting the categorie names above the carousel
    func setCategory(index: Int){
        switch(items[index].getName()){
            case "Game of War - Fire Age":
            categoryMessage.text = "Categorie: Berichten"
            categoryMessage.layoutIfNeeded()
            case "Clash of Clans":
            categoryMessage.text = "Categorie: Mededelingen"
            categoryMessage.layoutIfNeeded()
        default:
            categoryMessage.text = "Geen categorie"
            categoryMessage.layoutIfNeeded()
            break
            
        }
    }
    
    // Function for checking if the index from the carousel changed
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!){
        
        // Stop the synthesizer, if there are any sentences and reload data
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        self.carousel.reloadData()
    }
    
    func speechView(speechSynthesizer: AVSpeechSynthesizer, speech: String){
        var mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string:speech)
        
        mySpeechUtterance.rate = 0.06 // Setting rate of the voice
        mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: "nl-NL")
        println("\(mySpeechUtterance.speechString)")
        
        // First sentence will be called without delay
        if(speech.rangeOfString("Begin bericht") == nil){
            mySpeechUtterance.preUtteranceDelay = 0.3
        }
        
        // Say the sentence
        speechSynthesizer .speakUtterance(mySpeechUtterance)
       
        //speechSynthesizer.pauseSpeakingAtBoundary(mySpeechUtterance)
    }

    
    /* For calling View programmaticlly
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("ContentView") as UIViewController
    self.presentViewController(vc, animated: true, completion: nil)
    */
    
    /* For making an Alert dialog with OK button
    var alert = UIAlertController(title:  "The index", message: String(index), preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
    */
}


