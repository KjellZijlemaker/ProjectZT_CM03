
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

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, deleteMessageItem, messageOpenend
{
    //# MARK: - Array for all the items / settings to be loaded inside the carousel
    var messages: [Message] = []
    var pictures: [UIImage!] = []
    
    //# MARK: - Variables for adding new items to the array
    var txtField: UITextField!
    var dots: RSDotsView!
    var totalNewItems = 0 // For total of new items (Non realtime appended)
    var totalNewItemsRealtime = 0 // For total of new items (realtime appended)
    
    //# MARK: - Variables for appending messages / news
    var appendedMessages: [Message] = []
    
    // For checking if data is appending or not. Important for playing the speech or not inside the view,
    // when reloading the carousel!
    var isAppending = false
    
    
    //# MARK: - Speech variables
    var speech = SpeechManager() // For speech
    
    //# MARK: - Variables for deleting messages
    var deleteditemIndexes:[String] = [] // Carousel indexes for deleting (user read)
    var messageIsOpenend: Bool = false // Checking if message has openend, so not the same item will be removed
    
    //# MARK: - User variables
    var keychain = Keychain(service: "com.visio.postduif")
    var token: String!
    var refreshToken: String!
    var isRefreshToken: Bool = true
    var userSettings: [Settings] = [] // For getting all the settings from user
    var speechEnabled: Bool = true
    
    // For passing on to the other ViewControllers
    var currentIndex: Int = 0
    var passToLogin: Bool = false
    let defaults = NSUserDefaults.standardUserDefaults() // Instead of key, use UserDefault
    
    var sound = SoundManager(resourcePath: "Roekoe", fileType: "m4a") // For the sounds
    var dataTimer = NSTimer() // Timer for getting data (appending)
    
    var itemAlreadyChecked: Bool = false // For indicating that item was already appended, so no appending to messages array needed
    
    //# MARK: - Outlets for displaying labels / carousel
    @IBOutlet var carousel : iCarousel!
    @IBOutlet weak var categoryMessage: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func awakeFromNib() {
        
        // Getting the tokens
        self.token =  self.defaults.stringForKey("token")//keychain.get("token")
        self.refreshToken = self.defaults.stringForKey("refreshToken")//keychain.get("refreshToken")
        
        
        // If both tokens are empty, user has to login
        if(token == nil || refreshToken == nil){
            self.passToLogin = true
            
        }
        else{
            // Getting UserID
            var userID = ""
            
            // Getting the settings by UserID
            getUserSettings(userID)
            
            // Getting the app data and fill it in the global array
            getAppData(token!)
        
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Setting inital settings for swipe gestures
        self.carousel.userInteractionEnabled = true
        self.carousel.delegate = self
        self.carousel.type = .Custom
        self.carousel.scrollEnabled = false
        
        let logoutButton   = UIButton.buttonWithType(UIButtonType.System) as UIButton
        logoutButton.frame = CGRectMake(20, 20, 130, 130)
        logoutButton.userInteractionEnabled = true
        
        self.view.addSubview(logoutButton)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "logoutButtonAction:")
        logoutButton.addGestureRecognizer(longPressRecognizer)
        
        let overLayButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        overLayButton.frame = CGRectMake(840, 10, 180, 170)
        overLayButton.userInteractionEnabled = true
        self.view.addSubview(overLayButton)
        
        let longer = UILongPressGestureRecognizer(target: self, action: "scrollToLastIndex:")
        overLayButton.addGestureRecognizer(longer)
        self.view.addSubview(overLayButton)
            
            // Setting up the views and other misc
            self.setupViewController()
            self.setupBackgroundForegroundInit()
            self.setupTimerInit()
        
    }
    
    
    // Only when the keys are empty!!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
        if(passToLogin){
            // Dismiss the controller
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
                let secondPresentingVC = self.presentingViewController?.presentingViewController;
                secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
                
            });
            self.dataTimer.invalidate()
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //# MARK: - Gesture control methods
    //=================================================================================================
    
    //------------Dubble tap method for opening new view--------------//
    func singleTapped(){
        
        if(!self.messages.isEmpty){
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
    }
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        if(!self.messages.isEmpty){
            self.speech.stopSpeech()
            self.carousel.scrollByNumberOfItems(-1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
    }
    
    //------------Swipe method to the left--------------//
    func leftSwiped(){
        if(!self.messages.isEmpty){
            self.speech.stopSpeech()
            self.carousel.scrollByNumberOfItems(1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
        
    }
    
    //------------Swipe method to the left--------------//
    func upSwiped(){
        if(!self.messages.isEmpty){
            // carousel.scrollByNumberOfItems(1, duration: 0.25)
            appendAppData()
        }
    }
    
    //------------Swipe method to the left--------------//
    func newMessageTapped(){
        if(!self.messages.isEmpty){
            println("hello")
            self.carousel.scrollToItemAtIndex(self.messages.count-self.totalNewItems, animated: true)
        }
    }
    
    func swipeDown(){
        if(!self.messages.isEmpty){
            self.carousel.scrollToItemAtIndex(self.messages.count-1, animated: true)
            self.carousel.reloadItemAtIndex(self.messages.count-1, animated: false)
        }
    }
    
    func logoutButtonAction(sender: UILongPressGestureRecognizer) {
        self.speech.stopSpeech()
        if sender.state == UIGestureRecognizerState.Began
        {
            //self.keychain.removeAll()
            self.defaults.removeObjectForKey("token")
            self.defaults.removeObjectForKey("refreshToken")
            self.dataTimer.invalidate()
            
            // Dismiss the controller
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
                let secondPresentingVC = self.presentingViewController?.presentingViewController;
                secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
                
            });
            
            self.performSegueWithIdentifier("showLogin", sender: self)
            
        }
        
    }
    
    //# MARK: - View inits
    //=================================================================================================
    func setupViewController(){
        
        // How many items has the user got?
        self.speech.speechString("U heeft in totaal " + String(self.messages.count-1) + " nieuwe berichten")
        
        // Making textfield for new items
        self.txtField = UITextField(frame: CGRect(x: 43, y: 130, width: 15.00, height: 30.00));
        self.txtField.hidden = true
        self.txtField.borderStyle = UITextBorderStyle.Line
        self.txtField.backgroundColor = UIColor.yellowColor()
        self.txtField.userInteractionEnabled = false
        self.txtField.borderStyle = UITextBorderStyle.None
        self.txtField.text = String(self.totalNewItems)
        
        let tapNewMessage = UITapGestureRecognizer(target: self, action:Selector("newMessageTapped"))
        tapNewMessage.numberOfTapsRequired = 2
        
        // Making dot animation for new item
        self.dots = RSDotsView(frame: CGRectMake(870, -30, 300, 300))
        self.dots.dotsColor = UIColor.yellowColor()
        self.dots.hidden = true
        self.dots.addGestureRecognizer(tapNewMessage)
        self.view.addSubview(self.dots)
        
        
        //# MARK: - Gesture methods
        //=================================================================================================
        
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
        
        
        
        
        
        
    }
    
    //# MARK: - Setting up the backround and foreground notifications
    func setupBackgroundForegroundInit(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"totalNewItemsToForeground", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    
    //# MARK: - Setting up the timer(s)
    func setupTimerInit(){
            
            // Setup the viewController with Carousel
            dataTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("appendAppData"), userInfo: nil, repeats: true)
        
    }
    
    func scrollToLastIndex(){
        self.carousel.scrollToItemAtIndex(self.carousel.numberOfItems, animated: true)
    }
    
    
    //# MARK: - Carousel methods
    //=================================================================================================
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
    {
        var label: UILabel! = nil
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            
            //self.speech.stopSpeech()
            
            // BUG: carousel sometimes will begin at -1?? No item is displayed then. This is workaround
            if(index == 0){
                // self.carousel.scrollToItemAtIndex(0, animated: true)
            }
            
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
                if(self.speechEnabled){
                    if(!self.speech.isSpeaking()){
                        
                        // Check if the item is message or newsitem
                        if(self.messages[self.carousel.currentItemIndex].getType() == "1"){
                            var textToSend:[String] = []
                            
                            textToSend.append(String(index+1) + "e " + " Ongelezen bericht")
                            textToSend.append("Onderwerp: " + self.messages[index].getSubject())
                            textToSend.append("Tik op het scherm om het bericht te openen")
                            
                            
                            //TODO: Check JSON if user has speech in his settings
                            self.speech.speechArray(textToSend)
                        }
                        else{
                            var textToSend:[String] = []
                            
                            textToSend.append(String(index+1) + "e " + " Ongelezen nieuwsbericht")
                            textToSend.append("Titel: " + self.messages[index].getSubject())
                            textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                            
                            
                            //TODO: Check JSON if user has speech in his settings
                            self.speech.speechArray(textToSend)
                        }
                       
                        
                    }
                }
            }
            
            
        }
        
        
        // If the number is lower then two there will no appending in the carousel, but items will be decremented for array
        if(self.carousel.numberOfItems >= 2){
            println("Total items: " + String(self.totalNewItems))
            println("Total realtime items: " + String(self.totalNewItemsRealtime))
            if(self.dots != nil){
                
                if(self.carousel.currentItemIndex == self.carousel.numberOfItems - 1 && self.totalNewItems > 0 || self.totalNewItemsRealtime > 0){
                    
                    // tell the total of new items
                    if(self.speechEnabled){
                        if(self.speech.isSpeaking()){
                            self.newItemsToSpeech(self.totalNewItems)
                            self.sound.playSound() // Play the ROEKOE sound
                        }
                       
                        self.speech.stopSpeech() // Solving bug speeching 2 times message
                    }
                    
                    self.dots.hidden = false
                    self.txtField.hidden = false // New items, so unhide textView
                    
                    // If the realtime items are not 0, decrement the counter
                    if(self.itemAlreadyChecked && self.totalNewItemsRealtime > 0){ // TODO: Delete itemalreadychecked?
                        
                        for i in 0...self.totalNewItemsRealtime-1{
                            self.totalNewItemsRealtime--
                        }
                        self.itemAlreadyChecked = false
                        
                        // If the total items are not 0, append it to the carousel
                        if(self.totalNewItems > 0){
                            for i in index+1...index+self.totalNewItems{
                                self.carousel.insertItemAtIndex(i, animated: true) // Add new item at carousel
                                self.totalNewItems--
                            }
                        }
                    }
                        
                        // If realtime items are 0, there are only non-realtime items to append to carousel
                    else{
                        for i in index+1...index+self.totalNewItems{
                            self.carousel.insertItemAtIndex(i, animated: true) // Add new item at carousel
                            self.totalNewItems--
                        }
                    }
                    
                }
            }
        }
        else{
            if(self.carousel.currentItemIndex == self.carousel.numberOfItems - self.totalNewItems && self.totalNewItems > 0){
                self.dots.hidden = false
                self.txtField.hidden = false // New items, so unhide textView
                
                self.totalNewItems--
            }
        }
        
        // When reaching the last item inside the array
        if(self.carousel.currentItemIndex == self.messages.count-1 && self.totalNewItems == 0){
            
            // Will execute, only when not appending
            if(!isAppending){
                if(self.dots != nil){
                    self.txtField.removeFromSuperview()
                    self.dots.stopAnimating()
                    
                    // Hide it instead of removing view, otherwise txtView won't re appear
                    self.dots.hidden = true
                }
                
                if(self.speechEnabled){
                    self.speech.speechString("U heeft geen nieuwe berichten meer")
                }
            }
        }
        
        for i in 0...self.messages.count-1{
            // Setting the right images for each category
            setImages(i)
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
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return self.messages.count
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.9
        }
        return value
    }
    
    // Function for setting the images per category
    func setImages(index: Int){
        
        switch(self.messages[index].getType()){
        case "1":
            pictures.append(UIImage(named:"message.jpg"))
            
        case "2":
            pictures.append(UIImage(named:"news.jpg"))
            
        default:
            pictures.append(UIImage(named:"message.jpg"))
            
        }
        
    }
    
    // Setting the categorie names above the carousel
    func setCategory(index: Int){
        switch(self.messages[index].getType()){
        case "1":
            categoryMessage.text = "Categorie: Berichten"
            categoryMessage.layoutIfNeeded()
        case "2":
            categoryMessage.text = "Categorie: Nieuws"
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
    
    
    
    //# MARK: - User data methods
    //=================================================================================================
    
    // Function for getting the main app data and filling it into the array
    func getUserSettings(userID: String){
        
        var url = "http://84.107.107.169:8080/VisioWebApp/notificationTest"
        
        DataManager.getUserSettings(url){(settings) in
            
            // Transfering array to global array
            self.userSettings = settings
            
        }
        
    }
    
    
    //# MARK: - Messages and news data methods
    //=================================================================================================
    
    // Function for getting the main app data and filling it into the array
    func getAppData(tokenKey: String){
        
        var viewMayLoad: Bool = false
        var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + tokenKey
        
        // Notification for getting messages
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Berichten en nieuws ophalen"
        
        DataManager.getMessages(url){(messages) in
            
            // Transfering array to global array
            self.messages = messages
            
            // If not empty, enable getting initial data
            if(!messages.isEmpty){
                println(messages[0].getReturnCode())
                // If first message has returncode of 200, the token is correct and messages are fetched
                if(messages[0].getReturnCode() == "200"){
                    
                    // Iterate through all possible values
                    for r in 0...messages.count-1{
                        self.carousel.insertItemAtIndex(r, animated: true)
                        println(self.messages[r].getSubject())
                        
                        if(r == messages.count-1){
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                        }
                    }
                    viewMayLoad = true
                }
                    
                    // If the code is something else, the token is incorrect. Login again
                else{
                    if(messages[0].getReturnCode() == "400"){
                    if(self.isRefreshToken){
                        
                        self.isRefreshToken = false
                        self.getAppData("http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.refreshToken)
                    }
                   
                        // Close the view and go to login
                    else{
                        println("NOT correct")
                        
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                        
                        self.performSegueWithIdentifier("showLogin", sender: self)
                        
                        // Dismiss the controller
                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
                            let secondPresentingVC = self.presentingViewController?.presentingViewController;
                            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
                        });
                        }

                   
                    }
                    else{
                        var alert:SIAlertView  = SIAlertView(title: "Probleem", andMessage: "Probleem met server!!")
                        alert.titleFont = UIFont(name: "Verdana", size: 30)
                        alert.messageFont = UIFont(name: "Verdana", size: 26)
                        alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler: nil)
                        alert.buttonFont = UIFont(name: "Verdana", size: 30)
                        alert.transitionStyle = SIAlertViewTransitionStyle.Bounce
                        
                        alert.show()
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                        
//                        self.performSegueWithIdentifier("showLogin", sender: self)
//                        
//                        // Dismiss the controller
//                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
//                            let secondPresentingVC = self.presentingViewController?.presentingViewController;
//                            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
//                        });
                    

                    
                    }
                    
                }
            }
                
                // Else, there are no new messages
            else{
                if(self.speechEnabled){
                    self.speech.speechString("Er zijn geen berichten op dit moment")
                }
                else{
                    var alert:SIAlertView  = SIAlertView(title: "Melding", andMessage: "Er zijn geen berichten op dit moment")
                    alert.titleFont = UIFont(name: "Verdana", size: 30)
                    alert.messageFont = UIFont(name: "Verdana", size: 26)
                    alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler: nil)
                    alert.buttonFont = UIFont(name: "Verdana", size: 30)
                    alert.transitionStyle = SIAlertViewTransitionStyle.Bounce
                    
                    alert.show()
                }
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
            }
        }
    }
    
    // Function for appending app data, only and only if the number of items is greater then 1. This is for getting the new items only when at the end of the carousel
    func appendAppData(){
        if(!self.messageIsOpenend){
            if(self.carousel.numberOfItems > 1){
                
                isAppending = true // Now appending data, so speech may not execute
                var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token // URL for JSON
                
                DataManager.getMessages(url){(messages) in
                    
                    // If not empty, enable appending data
                    if(!messages.isEmpty){
                        
                        // Iterate through all possible values
                        for r in 0...messages.count-1{
                            
                            // If the index is null, it means a new element inside the array has been added
                            // AKA, a new item has been added
                            if(self.messages.getArrayIndex(r) == nil){
                                // If the animation is not already active, start it
                                if(!self.dots.isAnimating()){
                                    self.dots.startAnimating()
                                    self.dots.addSubview(self.txtField)
                                }
                                
                                self.totalNewItems++ // Append the number of items
                                self.txtField.text = String(self.totalNewItems) // Update the text
                                
                                self.messages.append(messages[r]) // Append the new message to existing view

                                
                            }
                        }
                        
                        
                        // Else, there are no more new items
                    }
                    
                }
            }
                
                // If there are less items at the current moment, realtime appending will be called
            else{
                println("OK")
                appendAppDataNoItems()
            }
        }
        
        
    }
    
    // Function for getting items realtime
    func appendAppDataNoItems(){
        isAppending = true // Now appending data, so speech may not execute
        var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token // URL for JSON
        
        DataManager.getMessages(url){(messages) in
            
            // If not empty, enable appending data
            if(!messages.isEmpty){
                
                
                // Iterate through all possible values
                for r in 0...messages.count-1{
                    
                    // If the index is null, it means a new element inside the array has been added
                    // AKA, a new item has been added
                    if(self.messages.getArrayIndex(r) == nil){
                        self.itemAlreadyChecked = true
                        //self.totalNewItems++ // Append the number of items
                        self.totalNewItemsRealtime++ // Append realtime for checking in carousel
                        self.txtField.hidden = false // New items, so unhide textView
                        self.txtField.text = String(self.totalNewItemsRealtime) // Update the text
                        self.dots.hidden = false
                        
                        // If the animation is not already active, start it
                        if(!self.dots.isAnimating()){
                            self.dots.startAnimating()
                            self.dots.addSubview(self.txtField)
                        }
                        
                        self.messages.append(messages[r]) // Append the new message to existing view
                        self.carousel.insertItemAtIndex(r, animated: true) // Add new item at carousel
                        
                        // tell the total of new items
                        if(self.speechEnabled){
                                self.newItemsToSpeech(self.totalNewItemsRealtime)
                            
                        }
                        
                        
                    }
                }
                
                
                // Else, there are no more new items
            }
            
        }
        
    }
    
    //# MARK: - UIBackground / Foreground methods
    //=================================================================================================
    func totalNewItemsToForeground(){
        if(totalNewItems >= 0){
            self.speech.stopSpeech()
            self.newItemsToSpeech(self.totalNewItems)
            self.carousel.scrollToItemAtIndex(self.messages.count-1-self.totalNewItems, animated: true) // Scroll to the section of last items
        }
        
    }
    
    //TODO: Make background stop speech
    
    
    func newItemsToSpeech(newItems: Int){
        var newMessageSpeechString = ""
        
        // Small check for grammar
        if(newItems == 1){
            newMessageSpeechString = "U heeft: " + String(self.totalNewItems) + " nieuw bericht"
        }
        else{
            newMessageSpeechString = "U heeft: " + String(self.totalNewItems) + " nieuwe berichten"
        }
        
        self.speech.speechString(newMessageSpeechString) // Say the speech
        
        self.carousel.reloadItemAtIndex(self.messages.count, animated: true) // Reload only the last item
        
    }
    
    
    // //# MARK: - Seque methods
    //=================================================================================================
    
    // Preparing the seque and send data with MessageContentViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showMessageContent"{
            let vc = segue.destinationViewController as MessageContentViewController
            vc.deletingMessage = self
            vc.openendMessage = self
            vc.message = self.messages[self.carousel.currentItemIndex]
            vc.carouselID = String(self.carousel.currentItemIndex)
            self.speech.stopSpeech()
            self.messageIsOpenend = true
        }
        if segue.identifier == "showNewsMessageContent"{
            let vc = segue.destinationViewController as NewsMessageViewController
            vc.delegate = self
            vc.newsMessageContent = self.messages[self.carousel.currentItemIndex].getContent()
            //            vc.deletingMessage = self
            //            vc.openendMessage = self
            self.speech.stopSpeech()
            self.messageIsOpenend = true
        }
        if segue.identifier == "showLogin"{
            let vc = segue.destinationViewController as LoginViewController
        }
        
    }
    
    
    //# MARK: - Deletion methods
    //=================================================================================================
    
    // Timer for deleting message. Is delegaded from NewsViewController
    func executeDeletionTimer(carouselMessageNumber: String) {
        self.messageIsOpenend = false
        
        // Check if array is not empty
        if(!self.deleteditemIndexes.isEmpty){
            
            // Check for items inside index for existing carousel number
            for i in 0...self.deleteditemIndexes.count-1{
                
                if(self.deleteditemIndexes[i] != carouselMessageNumber){
                    
                    // Appending the carouselMessageNumber to the deleteditemIndex
                    self.deleteditemIndexes.append(carouselMessageNumber)
                }
            }
            
        }
            
            // Index is empty, is first item of array
        else{
            
            // Appending the carouselMessageNumber to the deleteditemIndex
            self.deleteditemIndexes.append(carouselMessageNumber)
        }
        
        // Timer for periodically update the messages
        var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("deleteMessage"), userInfo: nil, repeats: false)
        
        
        
    }
    
    // Selector for making message read and deleting it from carousel
    func deleteMessage(){
        
        // Checks if message is openened or not
        if(!self.messageIsOpenend){
            
            // Check if index is empty or not for bounds of array
            if(!self.deleteditemIndexes.isEmpty){
                var carouselItemIndex = self.deleteditemIndexes.first?.toInt() // Getting first item from the array
                self.deleteditemIndexes.removeAtIndex(0) // Delete it
                var messageID = self.messages[carouselItemIndex!].getID() // Get the messageID for JSON array  --> Gaat hier fout
                var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/confirm?messageId=" + String(messageID)
                
                DataManager.checkMessageRead(url){(codeFromJSON) in
                    
                    if(codeFromJSON == "200"){
                        self.messages.removeAtIndex(carouselItemIndex!)
                        self.carousel.removeItemAtIndex(carouselItemIndex!, animated: true)
                        //self.carousel.scrollToItemAtIndex(carouselItemIndex!, animated: false)
                        //                self.carousel.reloadData()
                        if(self.messages.isEmpty){
                            self.speech.speechString("U heeft geen berichten op dit moment")
                        }
                    }
                }
            }
        }
    }
}


