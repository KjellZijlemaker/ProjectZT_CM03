
//
//  ViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit
import AVFoundation

// For checking if the array is out of bound
extension Array {
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func getArrayIndex(index: Int) -> T? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, deleteMessageItem
{
    // Array for all the items to be loaded inside the carousel
    var messages: [Message] = []
    var userSettings: [Settings] = []
    var pictures: [UIImage!] = []
    
    // TextField for showing new items inside the carousel
    var txtField: UITextField!
    var dots: RSDotsView!
    var totalNewItems = 0 // For total of new items
    
    var speech = SpeechManager()
    
    // For checking if data is appending or not. Important for playing the speech or not inside the view,
    // when reloading the carousel!
    var isAppending = false
    var noNewData = false
    
    
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
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("appendAppData"), userInfo: nil, repeats: true)
        
        // Making textfield for new items
        self.txtField = UITextField(frame: CGRect(x: 43, y: 130, width: 15.00, height: 30.00));
        self.txtField.hidden = true
        self.txtField.borderStyle = UITextBorderStyle.Line
        self.txtField.backgroundColor = UIColor.yellowColor()
        self.txtField.userInteractionEnabled = false
        self.txtField.borderStyle = UITextBorderStyle.None
        self.txtField.text = String(totalNewItems)
        
        // Making dot animation for new item
        self.dots = RSDotsView(frame: CGRectMake(870, -30, 300, 300))
        self.view.addSubview(dots)
        self.dots.dotsColor = UIColor.yellowColor()
        self.dots.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"totalNewItemsToForeground", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        
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
        
        //-----------up swipe gestures in view--------------//
        let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("upSwiped"))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)
        
        
        //-----------up swipe gestures in view--------------//
        let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("swipeDown"))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        let singleTap = UITapGestureRecognizer(target: self, action:Selector("singleTapped"))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    
        
        let tapNewMessage = UITapGestureRecognizer(target: self, action:Selector("newMessageTapped"))
        singleTap.numberOfTapsRequired = 1
        //self.dots.addGestureRecognizer(tapNewMessage)
        self.txtField.addGestureRecognizer(tapNewMessage)
    }
    
    //------------Dubble tap method for opening new view--------------//
    func singleTapped(){
        self.speech.stopSpeech()
        
        // Getting the current index of the carousel
        currentIndex = carousel.currentItemIndex
        
        
        switch self.messages[currentIndex].getCategory(){
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
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        self.speech.stopSpeech()
        self.carousel.scrollByNumberOfItems(-1, duration: 0.25)
        self.isAppending = false // Not appending, but swiping
    }
    
    //------------Swipe method to the left--------------//
    func leftSwiped(){
        self.speech.stopSpeech()
        self.carousel.scrollByNumberOfItems(1, duration: 0.25)
        self.isAppending = false // Not appending, but swiping
        
    }
    
    //------------Swipe method to the left--------------//
    func upSwiped(){
        // carousel.scrollByNumberOfItems(1, duration: 0.25)
        appendAppData()
    }
    
    //------------Swipe method to the left--------------//
    func newMessageTapped(){
        self.carousel.scrollToItemAtIndex(self.messages.count-self.totalNewItems, animated: true)
    }
    
    func swipeDown(){
        self.carousel.scrollToItemAtIndex(self.messages.count-1, animated: true)
        self.carousel.reloadItemAtIndex(self.messages.count-1, animated: false)
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return self.messages.count
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
    {
        var label: UILabel! = nil
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            
            //self.speech.stopSpeech()

            
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            view = UIImageView(frame:CGRectMake(0, 0, 200, 200))
            view.contentMode = .Center
            
            label = UILabel(frame:view.bounds)
            //label.frame = CGRectMake(-140, -150, 500, 100);
            label.frame = CGRectMake(-206, -200, 612, 100);
            label.backgroundColor = UIColor.whiteColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(50)
            label.textColor = UIColor.blackColor()
            label.tag = 1
            label.layoutIfNeeded()
            
            
            // view.addSubview(imageViewObject)
            view.addSubview(label)
            
            // Setting the right images for each category
            setImages(index)
            
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

            // Setting category per item inside the array
            setCategory(index)
            
            // Will execute, only when not appending
            if(!isAppending){
                
                if(!self.speech.isSpeaking()){
                    var textToSend:[String] = []
                    
                    textToSend.append(String(index+1) + "e " + " Ongelezen bericht")
                    textToSend.append("Onderwerp: " + self.messages[index].getSubject())
                    textToSend.append("Tik op het scherm om het bericht te openen")

                    
                    //TODO: Check JSON if user has speech in his settings
                    self.speech.speechArray(textToSend)
                    
                }
            }
            
            
        }
        
        
        
        if(self.dots != nil){
            
            if(self.carousel.currentItemIndex == self.carousel.numberOfItems - self.totalNewItems && self.totalNewItems > 0){
                
                self.totalNewItems--
                self.txtField.text = String(self.totalNewItems)
                
                if(self.totalNewItems == 0){
                    self.txtField.removeFromSuperview()
                    self.dots.stopAnimating()
                    
                    // Hide it instead of removing view, otherwise txtView won't re appear
                    self.dots.hidden = true
                    
                    // TODO: Add speech
                }
                
            }
        }
        
        
        // Not working yet!
        if(self.carousel.currentItemIndex == self.messages.count-1 && self.totalNewItems == 0){
            // Will execute, only when not appending
            if(!isAppending){
                self.speech.speechString("U heeft geen nieuwe berichten meer")
                
            }
        }
        
        
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(self.messages[index].getSubject())"
        (view as UIImageView!).image = self.pictures[index]
        
        return view
    }

    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.9
        }
        return value
    }
    
    // Function for getting the main app data and filling it into the array
    func getAppData(){
        
        var url = "http://84.107.107.169:8080/VisioWebApp/notificationTest"
        
        DataManager.getMessages(url){(messages) in
            
            // Transfering array to global array
            self.messages = messages
            
            // Iterate through all possible values
            for r in 0...self.messages.count-1{
                self.carousel.insertItemAtIndex(r, animated: true)
                println(self.messages[r].getSubject())
            }
        }
        
    }
    
    // Function for getting the main app data and filling it into the array
    func appendAppData(){
        
        
        isAppending = true // Now appending data, so speech may not execute
        var url = "http://84.107.107.169:8080/VisioWebApp/notificationTest" // URL for JSON
        
        DataManager.getMessages(url){(messages) in
            
            // Iterate through all possible values
            for r in 0...messages.count-1{
                
                // If the index is null, it means a new element inside the array has been added
                // AKA, a new item has been added
                if(self.messages.getArrayIndex(r) == nil){
                    self.totalNewItems++ // Append the number of items
                    println(self.totalNewItems)
                    self.txtField.hidden = false // New items, so unhide textView
                    self.txtField.text = String(self.totalNewItems) // Update the text
                    self.dots.hidden = false
                    
                    // If the anamation is not already active, start it
                    if(!self.dots.isAnimating()){
                        self.dots.startAnimating()
                        self.dots.addSubview(self.txtField)
                    }
                    
                    
                    self.messages.append(messages[r]) // Append the new message to existing view
                    self.carousel.insertItemAtIndex(r, animated: true) // Add new item at carousel
                    
                    // tell the total of new items
                    self.totalNewItemsToSpeech()
                    
                    /*// Extra check to check if the item is really new in the array(Optional)
                    for o in 0...self.items.count-1{
                    
                    // If the items do not match, the item is new and can be appended (Must be ID)
                    if(self.items[o].getName() != messages[r].getName()){
                    
                    
                    break
                    }*/
                    
                    
                }
                
                // Else, there are no more new items
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
        
        switch(self.messages[index].getSubject()){
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
        switch(self.messages[index].getSubject()){
        case "fesees":
            categoryMessage.text = "Categorie: Berichten"
            categoryMessage.layoutIfNeeded()
        case "lol":
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
        println(self.carousel.currentItemIndex)
            speech.stopSpeech()
            self.carousel.reloadItemAtIndex(self.carousel.currentItemIndex, animated: false)
    }
    
    
    
    // UIBackground / Foreground methods
    //=================================================================================================
    func totalNewItemsToForeground(){
        if(totalNewItems >= 0){
            self.totalNewItemsToSpeech()
            self.carousel.scrollToItemAtIndex(self.messages.count-1-self.totalNewItems, animated: true) // Scroll to the section of last items
        }
        
    }
    
    //TODO: Make background stop speech
    
    
    func totalNewItemsToSpeech(){
        var newMessageSpeechString = ""
        
        // Small check for grammar
        if(self.totalNewItems == 1){
            newMessageSpeechString = "U heeft: " + String(self.totalNewItems) + " nieuw bericht"
        }
        else{
            newMessageSpeechString = "U heeft: " + String(self.totalNewItems) + " nieuwe berichten"
        }
        
        self.speech.speechString(newMessageSpeechString) // Say the speech
        
        self.carousel.reloadItemAtIndex(self.messages.count, animated: true) // Reload only the last item
        
    }
    
    
    // Seque methods
    //=================================================================================================
    // Preparing the seque and send data with MessageContentViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showMessageContent"{
            let vc = segue.destinationViewController as MessageContentViewController
            vc.delegate = self
            vc.message = self.messages[self.carousel.currentItemIndex]
            self.speech.stopSpeech()
        }
        if segue.identifier == "showNewsMessageContent"{
            let vc = segue.destinationViewController as NewsMessageViewController
            vc.delegate = self
            vc.newsMessageContent = self.messages[self.carousel.currentItemIndex].getContent()
            self.speech.stopSpeech()
        }
    }

    // Timer for deleting message. Is delegaded from NewsViewController
    func executeDeletionTimer() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("deleteMessage"), userInfo: nil, repeats: false)
    }
    
    // Selector for deleting message
    func deleteMessage(){
        var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/confirm?messageId=" + self.messages[self.carousel.currentItemIndex].getID()
        
        DataManager.checkMessageRead(url){(codeFromJSON) in
            
            println(codeFromJSON)
            
            if(codeFromJSON == "200"){
                self.messages.removeAtIndex(self.carousel.currentItemIndex)
                self.carousel.removeItemAtIndex(self.carousel.currentItemIndex, animated: true)
                self.carousel.reloadData()
            }
        }
    }
    
    
    /* When getting appended data from the datamanager
    func appendAppData(){
    
    var url = "http://84.107.107.169:8080/VisioWebApp/notificationTest"
    
    DataManager.appendMessages(url, items: self.items){(messages) in
    
    // Iterate through all possible values
    for r in 0...messages.count{
    if(!messages.isEmpty){
    self.items.append(messages[0])
    self.carousel.insertItemAtIndex(r, animated: true)
    println("YAY")
    }
    
    }
    
    }
    
    }*/
    
    
    /* Function for activating when view will dissapear
    override func viewWillDisappear(animated: Bool) {
    var oldItems: [Message] = self.items
    
    // URL for the JSON
    var url = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=3/json"
    
    // Getting the app data and fill it in the global array
    getAppData(url)
    
    println(oldItems)
    println(items)
    
    for i in 0...items.count-1{
    if(oldItems[i].getName() != items[i].getName()){
    println("Dat is een nieuwe!")
    }
    }
    
    }*/
    
    
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


