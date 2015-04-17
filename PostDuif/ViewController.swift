
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
    var pictures: [UIImage!] = []
    
    //# MARK: - Counters for the amount of messages and news
    var firstItem: Bool = true
    var messagesCount = 0
    var newsCount = 0
    
    //#MARK: - Counters and booleans for amount of new messages and news
    var newMessagesCount = 0
    var newNewsCount = 0
    
    //# MARK: - Variables for adding new items to the array
   
    var totalNewItems = 0 // For total of new items (Non realtime appended)
    var totalNewItemsRealtime = 0 // For total of new items (realtime appended)
    
    //# MARK: - Variables for appending messages / news
    var appendedMessages: [Item] = []
    
    // For checking if data is appending or not. Important for playing the speech or not inside the view,
    // when reloading the carousel!
    var isAppending = false
    var indexBeginningNewMessages = 0 // Index when the new messages appended (for counting down the new items in notification)
    var indexBeginningNewNews = 0 // Index when the new messages appended (for counting down the new items in notification)

    var boundaryBeginningNewItems = 0 // Int for giving the total of old items before the new items appended
    var oldBoundaryBeginningNewItems = 0
    
    //# MARK: - Variables for deleting messages
    var deleteditemIndexes:[String] = [] // Carousel indexes for deleting (user read)
    var messageIsOpenend: Bool = false // Checking if message has openend, so not the same item will be removed
    
    //# MARK: - User variables
    var keychain = Keychain(service: "com.visio.postduif")
    
    // For passing on to the other ViewControllers
    var passToLogin: Bool = false
    let defaults = NSUserDefaults.standardUserDefaults() // Instead of key, use UserDefault
    
    var dataTimer = NSTimer() // Timer for getting data (appending)
    
    //# MARK: Views
    var notificationDot: NotificationDot!
    var notificationText: NotificationText!
    
    //# MARK: Models
    var items: [Item] = []
    var userSettings: Settings = Settings() // For getting all the settings from user
    var token: Token = Token()

    //# MARK: Managers
    var speech = SpeechManager() // For speech
    var sound = SoundManager(resourcePath: "Roekoe", fileType: "m4a") // For the sounds


    
    
    //# MARK: - Outlets for displaying labels / carousel
    @IBOutlet var carousel : iCarousel!
    @IBOutlet weak var categoryMessage: UILabel!
    
    override func awakeFromNib() {
        
        // If both tokens are empty, user has to login
        if(self.defaults.stringForKey("token") == nil || self.defaults.stringForKey("refreshToken") == nil){
            self.passToLogin = true
            
        }
        else{
            // Getting the tokens
            self.token.setToken(self.defaults.stringForKey("token")!)//keychain.get("token")
            self.token.setRefreshToken(self.defaults.stringForKey("refreshToken")!)//keychain.get("refreshToken")
            
            // Getting the settings by UserID
            getUserSettings(self.token.getToken())
            
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
        
        let logoutButton = LogoutButton().showLogoutButton()
        self.view.addSubview(logoutButton)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "logoutButtonAction:")
        logoutButton.addGestureRecognizer(longPressRecognizer)
        
        // Setting up the views and other misc
        self.setupViewController()
        self.setupBackgroundForegroundInit()
    }
    
    
    // Only when the keys are empty!!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
        if(passToLogin){
            
            // Sending user back to login phase
            self.goToLogin()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //# MARK: - Gesture control methods
    //=================================================================================================
    
    //------------Dubble tap method for opening new view--------------//
    func singleTapped(){
        
        if(!self.items.isEmpty){
            self.speech.stopSpeech()
            
            switch self.items[self.carousel.currentItemIndex].getType(){
            case "1":
                // For performing the seque inside the storyboard
                performSegueWithIdentifier("showMessageContent", sender: self)
                println("message")
            case "2":
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
        if(!self.items.isEmpty){
            self.speech.stopSpeech()
            self.carousel.scrollByNumberOfItems(-1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
    }
    
    //------------Swipe method to the left--------------//
    func leftSwiped(){
        if(!self.items.isEmpty){
            self.speech.stopSpeech()
            self.carousel.scrollByNumberOfItems(1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
        
    }
    
    //------------Swipe method to the left--------------//
    func upSwiped(){
        if(!self.items.isEmpty){
            // carousel.scrollByNumberOfItems(1, duration: 0.25)
            //appendAppData()
        }
    }
    
    //------------Swipe method to the left--------------//
    func newMessageTapped(){
        if(!self.items.isEmpty){
            println("hello")
            self.carousel.scrollToItemAtIndex(self.items.count-self.totalNewItems, animated: true)
        }
    }
    
    func swipeDown(){
        if(!self.items.isEmpty){
            self.carousel.scrollToItemAtIndex(self.items.count-1, animated: true)
            self.carousel.reloadItemAtIndex(self.items.count-1, animated: false)
        }
    }
        
    //# MARK: - View inits
    //=================================================================================================
    func setupViewController(){
        
        // Setup the notification text view
        self.notificationText = NotificationText()
        self.notificationText.makeNotificationTextView()
        self.view.addSubview(self.notificationText.getNotificationTextView())
        
        
        // Making dot animation for new item
        self.notificationDot = NotificationDot()
        self.notificationDot.makeDotView()
        self.notificationDot.hideDotView()
        self.view.addSubview(self.notificationDot.getDotView())
        
        
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
        dataTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("appendAppDataRealtime"), userInfo: nil, repeats: true)
        
    }
    
    //# MARK: - Carousel methods
    //=================================================================================================
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
        
        
        // If the number is lower then two there will no appending in the carousel, but items will be decremented for array
        if(self.carousel.numberOfItems >= 2){
            println("Total items: " + String(self.totalNewItems))
            println("Total realtime items: " + String(self.totalNewItemsRealtime))
            if(self.notificationDot != nil){
                
                if(self.carousel.currentItemIndex == self.carousel.numberOfItems - 1 && self.totalNewItemsRealtime > 0){
                    
                    self.notificationDot.showDotView() // Show dot
                    self.notificationText.hideNotificationTextView() // New items, so unhide textView
                    
                    // If the realtime items are not 0, decrement the counter
                    if(self.totalNewItemsRealtime > 0){
                        
                        for i in 0...self.totalNewItemsRealtime-1{
                            self.totalNewItemsRealtime--
                        }
                    
                    }
                        
                    
                    
                }
                    // If realtime items are 0, there are only non-realtime items to append to carousel
                else if (self.carousel.currentItemIndex == self.messagesCount-1 && self.newsCount == 0){
                    self.appendAppData("0")
                }
                else if (self.carousel.currentItemIndex == self.messagesCount-1){
                    self.appendAppData("1")
                }
                else if (self.carousel.currentItemIndex == self.messagesCount + self.newsCount-1) {
                    self.appendAppData("2")
                }
                
            }
        }
        else{
            if(self.carousel.currentItemIndex == self.carousel.numberOfItems - self.totalNewItems && self.totalNewItems > 0){
                self.notificationDot.showDotView() // Show dot
                self.notificationText.hideNotificationTextView() // New items, so unhide textView
                
                self.totalNewItems--
            }
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(self.items[index].getSubject())"
        (view as UIImageView!).image = self.pictures[index]
        
        return view
    }
    
    func firstItemInCarousel(){
        /*
        First Total of items + first message will be played
        */
        if(self.firstItem){
            
            if (self.carousel.currentItemIndex == 0) {
                
                self.setCategory(self.carousel.currentItemIndex) // Setting the category
                
                self.firstItem = false
                
                
                
                var textToSend:[String] = [] // Array for sending message
                
                // Check if the item is message or newsitem
                if(self.items[self.carousel.currentItemIndex].getType() == "1"){
                    
                    textToSend.append(String(self.carousel.currentItemIndex+1) + "e " + " Ongelezen bericht")
                    textToSend.append("Onderwerp: " + self.items[self.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om het bericht te openen")
                    
                    
                    //TODO: Check JSON if user has speech in his settings
                    self.speech.speechArray(textToSend)
                }
                else{
                    
                    textToSend.append(String(self.carousel.currentItemIndex+1) + "e " + " Ongelezen nieuwsbericht")
                    textToSend.append("Titel: " + self.items[self.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                    
                    
                    //TODO: Check JSON if user has speech in his settings
                    self.speech.speechArray(textToSend)
                }
            }
            
        }
    }
    
    // Function for checking if the index from the carousel changed
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!){
        
        println("categorie: " + self.items[self.carousel.currentItemIndex].getCategory())
        // Setting category per item inside the array
        self.setCategory(self.carousel.currentItemIndex)
        
        println("Berichten: " + String(newMessagesCount))
        println("Nieuws: " + String(newNewsCount))

        
        if(self.indexBeginningNewNews > 0 && self.carousel.currentItemIndex > self.indexBeginningNewNews){
            self.totalNewItems--
            self.notificationText.setNotificationTextView(String(self.newNewsCount)) // Update the text
            self.indexBeginningNewNews = self.carousel.currentItemIndex // Update the index
            self.newNewsCount--
            
            // If the totalNewItems is 0, delete the notification
            if(self.newNewsCount == 0){
                self.indexBeginningNewNews = 0
                if(self.notificationDot != nil){
                    self.notificationText.removeNotificationTextFromView() // Remove from view
                    self.notificationDot.getDotView().stopAnimating()
                    
                    // Hide it instead of removing view, otherwise txtView won't re appear
                    self.notificationDot.hideDotView()
                }
                
            }
        }
        else if(self.indexBeginningNewMessages > 0 && self.carousel.currentItemIndex > self.indexBeginningNewMessages){
            self.totalNewItems--
            self.notificationText.setNotificationTextView(String(self.newMessagesCount)) // Update the text
            self.indexBeginningNewMessages = self.carousel.currentItemIndex // Update the index
            self.newMessagesCount--
            
            // If the totalNewItems is 0, delete the notification
            if(self.newMessagesCount == 0){
                self.indexBeginningNewMessages = 0
                if(self.notificationDot != nil){
                    self.notificationText.removeNotificationTextFromView() // Remove from view
                    self.notificationDot.getDotView().stopAnimating()
                    
                    // Hide it instead of removing view, otherwise txtView won't re appear
                    self.notificationDot.hideDotView()
                }
                
            }
        }

        
        // Will execute, only when not appending
        if(!isAppending){
            
            // Will execute when it's not the first item anymore (for speech)
            if(!self.firstItem){
                if(self.userSettings.isSpeechEnabled()){
                    
                    var textToSend:[String] = [] // Array for sending message
                    
                    // Check if the item is message or newsitem
                    if(self.items[self.carousel.currentItemIndex].getType() == "1"){
                        
                        var currentItem = self.messagesCount - self.messagesCount + self.carousel.currentItemIndex + 1
                        
                        
                        textToSend.append(String(currentItem) + "e " + " Ongelezen bericht")
                        textToSend.append("Onderwerp: " + self.items[self.carousel.currentItemIndex].getSubject())
                        textToSend.append("Tik op het scherm om het bericht te openen")
                        
                        self.speech.speechArray(textToSend)
                    }
                        
                    else{
                        
                        var currentItem = self.carousel.currentItemIndex - messagesCount + 1
                        
                        textToSend.append(String(currentItem) + "e " + " Ongelezen nieuwsbericht")
                        textToSend.append("Titel: " + self.items[self.carousel.currentItemIndex].getSubject())
                        textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                        
                        self.speech.speechArray(textToSend)
                    }
                }
                self.carousel.reloadItemAtIndex(self.carousel.currentItemIndex, animated: false)
            }
            
        }
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return self.items.count
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.9
        }
        return value
    }
    
    
    //# MARK: - Methods for setting images and category
    //=================================================================================================
    
    // Function for setting the images per category
    func setImages(index: Int){
        
        switch(self.items[index].getType()){
        case "1":
            pictures.append(UIImage(named:"message.jpg"))
            
        case "2":
            pictures.append(UIImage(named:"news.jpg"))
            
        default:
            pictures.append(UIImage(named:"message.jpg"))
            
        }
        
    }
    
    func appendImage(index: Int){
        switch(self.items[index].getType()){
            
        case "1":
            pictures.insert(UIImage(named:"message.jpg"), atIndex: index)
            println(index)
        case "2":
            pictures.insert(UIImage(named:"news.jpg"), atIndex: index)
            println(index)
        default:
            pictures.insert(UIImage(named:"message.jpg"), atIndex: index)
            
        }
        
    }
    
    // Removing the image at index
    func removeImage(index:Int ){
        self.pictures.removeAtIndex(index)
        
    }
    
    
    // Setting the categorie names above the carousel
    func setCategory(index: Int){
        
        categoryMessage.text = "Categorie: " + self.items[index].getCategory()
        
//        switch(self.items[index].getType()){
//        case "1":
//            categoryMessage.text = "Categorie: Berichten"
//            categoryMessage.layoutIfNeeded()
//        case "2":
//            categoryMessage.text = "Categorie: Nieuws"
//            categoryMessage.layoutIfNeeded()
//        default:
//            categoryMessage.text = "Geen categorie"
//            categoryMessage.layoutIfNeeded()
//            break
//            
//        }
    }
    
    
    
    
    
    
    //# MARK: - User data methods
    //=================================================================================================
    
    // Function for getting the main app data and filling it into the array
    func getUserSettings(tokenKey: String){
        
        var url = "http://84.107.107.169:8080/VisioWebApp/API/clientSettings?tokenKey=" + tokenKey
        
        UserManager.getUserSettings(url){(settings) in
            
            // If the setting has a return code of 200, all went OK
            if(settings.getReturnCode() == "200"){
                
                // Transfering array to global array
                self.userSettings = settings
                
                if(self.userSettings.getColorType() != "default"){
                    self.carousel.backgroundColor = self.UIColorFromRGB(self.userSettings.getColorType())
                }
                if(self.userSettings.getContrastType() != "default"){
                }
                
                self.token.hasRefreshToken(true) // For getting the messages
                
                // Getting the app data and fill it in the global array
                self.getAppData(self.token.getToken())
            }
            else if(settings.getReturnCode() == "400"){
                if(self.token.isRefreshToken()){
                    self.token.hasRefreshToken(false)
                }
                else{
                    // Send user back to login phase
                    self.goToLogin()
                }
            }
            else{
                self.setAlertView("Probleem", message: "Kon instellingen niet ophalen")
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
            }
        }
        
    }
   
    
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        var scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
    
    //# MARK: - items and news data methods
    //=================================================================================================
    
    // Function for getting the main app data and filling it into the array
    func getAppData(tokenKey: String){
        
        var viewMayLoad: Bool = false
        var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + tokenKey
        self.oldBoundaryBeginningNewItems = self.items.count-1

        self.setLoadingView("Berichten en nieuws ophalen")
        
        DataManager.getItems(url){(items) in
            
            // If not empty, enable getting initial data
            if(!items.isEmpty){

                
                // If first message has returncode of 200, the token is correct and items are fetched
                if(items[0].getReturnCode() == "200"){
                    
                    
                    // Transfering array to global array
                    for i in 0...items.count-1{
                        if(items[i].getType() == "1"){
                            self.messagesCount++
                            self.items.append(items[i])
                            
                            // Setting the right images for each category
                            self.setImages(i)
                            
                            self.carousel.insertItemAtIndex(i, animated: true) // Insert items at last index
                            if(self.messagesCount == self.userSettings.getPrivateMessageLimit()){
                                break
                            }
                        }
                    }
                    
                    for l in 0...items.count-1{
                        if(items[l].getType() == "2"){
                            self.newsCount++
                            self.items.append(items[l])
                            
                            // Setting the right images for each category
                            self.setImages(l)
                            
                            self.carousel.insertItemAtIndex(l, animated: true) // Insert items at last index
                            if(self.newsCount == self.userSettings.getNewsMessageLimit()){
                                break
                            }
                        }
                    }
                    
                    // Seepching total of items
                    self.speech.speechString("U heeft in totaal: " + String(self.messagesCount) + " nieuwe berichten, en " + String(self.newsCount) + " nieuwe nieuwsberichten")
                    
                    self.firstItemInCarousel() // Speeching the first item inside the carousel
                    
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                    viewMayLoad = true
                }
                    
                    // If the code is something else, the token is incorrect. Login again
                else{
                    if(items[0].getReturnCode() == "400"){
                        if(self.token.isRefreshToken()){
                            
                            self.token.hasRefreshToken(false)
                            self.getAppData("http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token.getRefreshToken())
                        }
                            
                            // Close the view and go to login
                        else{
                            println("NOT correct")
                            
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                            
                            // Send user back to login phase
                            self.goToLogin()
                        }
                        
                    }
                    else{
                        self.setAlertView("Probleem", message: "Kon berichten niet ophalen")
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                        
                    }
                    
                }
            }
                
                // Else, there are no new items
            else{
                if(self.userSettings.isSpeechEnabled()){
                    self.speech.speechString("Er zijn geen berichten op dit moment")
                }
                else{
                    self.setAlertView("Melding", message: "Er zijn geen berichten op dit moment")
                }
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
            }
        }
    }
    
    // For loading screen
    func setLoadingView(title: String){
        // Notification for getting items
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = title
    }
    
    // Setting alertView for notification user
    func setAlertView(title: String, message: String){
        var alert:SIAlertView  = SIAlertView(title: title, andMessage: message)
        alert.titleFont = UIFont(name: "Verdana", size: 30)
        alert.messageFont = UIFont(name: "Verdana", size: 26)
        alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler: nil)
        alert.buttonFont = UIFont(name: "Verdana", size: 30)
        alert.transitionStyle = SIAlertViewTransitionStyle.Bounce
        
        alert.show()
    }
    
    // Function for going to the login phase
    func goToLogin(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            
        });
        
        // Invalidate timer if present
        if(self.dataTimer.valid){
            self.dataTimer.invalidate() // Invalidate the timer
        }
        
        // Remove the keys if present
        if(self.defaults.objectForKey("token") != nil && self.defaults.objectForKey("refreshToken") != nil){
            
            self.defaults.removeObjectForKey("token")
            self.defaults.removeObjectForKey("refreshToken")
        }
       
        self.performSegueWithIdentifier("showLogin", sender: self) // Go to the login screen
    }
    
    // Function for appending app data, only and only if the number of items is greater then 1. This is for getting the new items only when at the end of the carousel
    func appendAppData(type: String){
        if(!self.messageIsOpenend){
            
                isAppending = true // Now appending data, so speech may not execute
                var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token.getToken() // URL for JSON
            
            if(type == "1"){
                self.indexBeginningNewMessages = self.messagesCount-1 // Index when new items will begin to append

            }
            else{
                self.indexBeginningNewNews = self.messagesCount + self.newsCount-1 // Index when new items will begin to append

            }
            
                self.oldBoundaryBeginningNewItems = self.boundaryBeginningNewItems
                self.boundaryBeginningNewItems = self.indexBeginningNewMessages // Transfer to boundary for counting
            
            
                self.setLoadingView("Nieuwe berichten laden")
                DataManager.getItems(url){(items) in
                    
                    // If not empty, enable appending data
                    if(!items.isEmpty){
                        
                        var idArrayOld: [Int] = []
                        var idArrayNew: [Int] = []
                        var newIDArray: [Int] = []
                        var newArray: [AnyObject] = []
                        
                        if(!items.isEmpty){
                            for j in 0...items.count-1{
                                
                                // If 0, also the news should be appended because there is none yet
                                if(type != "0"){
                                    // Check if the type is the same (for appending at the according index)
                                    if(items[j].getType() == type){
                                        idArrayNew.append(items[j].getID().toInt()!)
                                        
                                    }
                                }
                                else{
                                    idArrayNew.append(items[j].getID().toInt()!)
                                }
                                
                                
                                
                            }
                        }
                        
                        if(!self.items.isEmpty){
                            for i in 0...self.items.count-1{
                                
                                // If 0, also the news should be appended because there is none yet
                                if(type != "0"){
                                    
                                    // Check if the type is the same (for appending at the according index)
                                    if(self.items[i].getType() == type){
                                        idArrayOld.append(self.items[i].getID().toInt()!)
                                    }
                                }
                                else{
                                    idArrayOld.append(self.items[i].getID().toInt()!)
                                }
                                
                            }
                        }
                        
                        var set1 = NSMutableSet(array: idArrayOld)
                        var set2 = NSMutableSet(array: idArrayNew)
                        
                        set2.minusSet(set1)
                        
                        newArray = set2.allObjects
                        println(newArray)
                        
                        if(!newArray.isEmpty){
                            for k in 0...newArray.count-1{
                                newIDArray.append(newArray[k] as Int)
                            }
                        }
                        
                        if(newIDArray.count != 0){
                            var indexHasChanged = false
                            for l in 0...items.count-1{
                                
                                for k in 0...newIDArray.count-1{
                                    if(items[l].getID().toInt() == newIDArray[k]){
                                        
                                        if(items[l].getType() == "1"){
                                        
                                            if(l <= self.userSettings.getPrivateMessageLimit()){
                                                indexHasChanged = true
                                                
                                            // If the animation is not already active, start it
                                            if(!self.notificationDot.getDotView().isAnimating()){
                                                self.notificationDot.getDotView().startAnimating()
                                                self.notificationDot.getDotView().addSubview(self.notificationText.getNotificationTextView())
                                            }
                                            
                                            self.totalNewItems++ // Append the number of items
                                            self.notificationText.setNotificationTextView(String(self.totalNewItems)) // Update the text
                                            self.notificationText.showNotificationTextView()
                                            self.notificationDot.showDotView() // Show dot
                                            
                                            self.items.insert(items[l], atIndex: self.messagesCount)
                                            
                                            self.appendImage(self.messagesCount)
                                            self.carousel.insertItemAtIndex(self.messagesCount, animated: true)
                                           
                                            //Add the amount of messages or news
                                            self.messagesCount++
                                            self.newMessagesCount++
                                            }
                                            else{
                                                break
                                            }
                                        }
                                        else{
                                            if(l <= self.userSettings.getNewsMessageLimit()){
                                            
                                                indexHasChanged = true

                                                
                                            // If the animation is not already active, start it
                                            if(!self.notificationDot.getDotView().isAnimating()){
                                                self.notificationDot.getDotView().startAnimating()
                                                self.notificationDot.getDotView().addSubview(self.notificationText.getNotificationTextView())
                                            }
                                            
                                            self.totalNewItems++ // Append the number of items
                                            self.notificationText.setNotificationTextView(String(self.totalNewItems)) // Update the text
                                            self.notificationText.showNotificationTextView()
                                            self.notificationDot.showDotView() // Show dot
                                            
                                            var indexNewsCount = self.messagesCount + self.newsCount
                                            self.items.insert(items[l], atIndex: indexNewsCount)
                                            self.appendImage(indexNewsCount)
                                           self.carousel.insertItemAtIndex(indexNewsCount, animated: true)
                                           
                                            //Add the amount of messages or news
                                            self.newsCount++
                                            self.newNewsCount++
                                            }
                                            else{
                                                break
                                            }
                                        }
                                    
                                        
                                        continue
                                    }
                                    
                                    
                                }
                            }
                            self.isAppending = false
                            
                            if(indexHasChanged){
                            // tell the total of new items
                            if(self.userSettings.isNotificationSoundEnabled()){
                                if(self.speech.isSpeaking()){
                                    if(self.newMessagesCount > 0 && self.newNewsCount > 0){
                                        self.newItemsToSpeech(self.newMessagesCount, type: "1")
                                        self.newItemsToSpeech(self.newNewsCount, type: "2")
                                    }
                                    else if(self.newMessagesCount > 0){
                                        self.newItemsToSpeech(self.newMessagesCount, type: "1")
                                    }
                                    else{
                                        self.newItemsToSpeech(self.newNewsCount, type: "2")
                                    }
                                    
                                    self.sound.playSound() // Play the ROEKOE sound
                                    //self.speech.stopSpeech()
                                }
                                
                            }
                            self.carousel.reloadData()
                        }
                    }
                        
                }
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification

            }
            
            
        }
        
        
    }
    
    // Function for getting items realtime
    // TODO: (IS REPETATIVE CODE, MUST PUT IT IN APPENDING DATA METHOD!!!)
    func appendAppDataRealtime(){
        isAppending = true // Now appending data, so speech may not execute
        var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token.getToken() // URL for JSON
        self.indexBeginningNewMessages = self.messagesCount-1 // Index when new items will begin to append
        self.indexBeginningNewNews = self.messagesCount-1 + self.newsCount-1 // Index when new items will begin to append
        self.boundaryBeginningNewItems = self.indexBeginningNewMessages // Transfer to boundary for counting

        DataManager.getItems(url){(items) in
            
            // If not empty, enable appending data
            if(!items.isEmpty){
                
                
                var idArrayOld: [Int] = []
                var idArrayNew: [Int] = []
                var newIDArray: [Int] = []
                var newArray: [AnyObject] = []
                
                if(!items.isEmpty){
                    for j in 0...items.count-1{
                        idArrayNew.append(items[j].getID().toInt()!)
                        
                    }
                }
                
                if(!self.items.isEmpty){
                    for i in 0...self.items.count-1{
                        idArrayOld.append(self.items[i].getID().toInt()!)
                    }
                }
                
                var set1 = NSMutableSet(array: idArrayOld)
                var set2 = NSMutableSet(array: idArrayNew)
                
                set2.minusSet(set1)
                
                newArray = set2.allObjects
                println(newArray)
                
                if(!newArray.isEmpty){
                    for k in 0...newArray.count-1{
                        newIDArray.append(newArray[k] as Int)
                    }
                }
                
                if(newIDArray.count != 0){
                    for l in 0...items.count-1{
                        
                        for k in 0...newIDArray.count-1{
                            if(items[l].getID().toInt() == newIDArray[k]){
                                
                                self.totalNewItemsRealtime++ // Append realtime for checking in carousel
                                
                                
                                if(!self.firstItem){ // Will execute if it's not the first item anymore (for speech)
                                    if(self.totalNewItemsRealtime > 0 || self.carousel.currentItemIndex != 0){
                                        // tell the total of new items
                                        if(self.userSettings.isSpeechEnabled()){
                                            if(self.items[l].getType() == "1"){
                                                self.newItemsToSpeech(self.totalNewItemsRealtime, type: "1")

                                            }
                                            else{
                                                self.newItemsToSpeech(self.totalNewItemsRealtime, type: "2")

                                            }
                                            
                                        }
                                    }
                                }
                                if(self.carousel.numberOfItems == 0){
                                    self.totalNewItemsRealtime--
                                }
                                
                                if(self.carousel.currentItemIndex != 0 || self.carousel.numberOfItems > 0){
                                    self.notificationText.showNotificationTextView() // New items, so unhide textView
                                    self.notificationText.setNotificationTextView(String(self.totalNewItemsRealtime)) // Update the text
                                    self.notificationDot.showDotView() // Show dot
                                    
                                    // If the animation is not already active, start it
                                    if(!self.notificationDot.getDotView().isAnimating()){
                                        self.notificationDot.getDotView().startAnimating()
                                        self.notificationDot.getDotView().addSubview(self.notificationText.getNotificationTextView())
                                    }
                                }
                                
                                self.items.append(items[l]) // Append the new message to existing view
                                self.carousel.insertItemAtIndex(l, animated: true) // Add new item at carousel
                                
                                // Add the amount of messages or news
                                if(self.items[l].getType() == "1"){
                                    self.messagesCount++
                                    self.newMessagesCount++
                                }
                                else{
                                    self.newsCount++
                                    self.newNewsCount++
                                }
                                
                                
                                continue
                            }
                            
                            
                        }
                    }
                    
                    self.isAppending = false

                    
                    
                                                self.carousel.reloadData() // If appended succesful, reload carousel
                    //                            self.speech.stopSpeech()
                }
                
            }
            
        }
        
    }
    
    //# MARK: - UIBackground / Foreground methods
    //=================================================================================================
    func totalNewItemsToForeground(){
        if(totalNewItems >= 0){
            self.speech.stopSpeech()
//            self.newItemsToSpeech(self.totalNewItems, "0")
//            self.carousel.scrollToItemAtIndex(self.items.count-1-self.totalNewItems, animated: true) // Scroll to the section of last items
        }
        
    }
    
    //TODO: Make background stop speech
    
    
    func newItemsToSpeech(newItems: Int, type: String){
        var newMessageSpeechString = ""
        var typeItem = ""
        if(type == "1"){
            // Small check for grammar
            if(newItems == 1){
                typeItem = "bericht"
            }
            else{
                typeItem = "berichten"
            }
        }
        else{
            // Small check for grammar
            if(newItems == 1){
                typeItem = "nieuwsbericht"
            }
            else{
                typeItem = "nieuwsberichten"
            }
        }
        
        newMessageSpeechString = "U heeft: " + String(newItems) + "nieuwe " + typeItem

        self.speech.speechString(newMessageSpeechString) // Say the speech
        
        //self.carousel.reloadItemAtIndex(self.messages.count, animated: true) // Reload only the last item
        
    }
    
    
    // //# MARK: - Seque methods
    //=================================================================================================
    
    // Preparing the seque and send data with MessageContentViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showMessageContent"{
            let vc = segue.destinationViewController as MessageContentViewController
            vc.deletingMessage = self
            vc.openendMessage = self
            vc.message = self.items[self.carousel.currentItemIndex]
            vc.userSettings = self.userSettings
            vc.carouselID = String(self.carousel.currentItemIndex)
            self.speech.stopSpeech()
            self.messageIsOpenend = true
        }
        if segue.identifier == "showNewsMessageContent"{
            let vc = segue.destinationViewController as NewsMessageViewController
            vc.deletingMessage = self
            vc.openendMessage = self
            vc.delegate = self
            vc.news = self.items[self.carousel.currentItemIndex]
            vc.userSettings = self.userSettings
            vc.carouselID = String(self.carousel.currentItemIndex)
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
    func executeDeletionTimer(carouselMessageNumber: String, _ type: String) {
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
        var timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector: Selector("deleteMessage:"), userInfo: type, repeats: false)
        
        
        
    }
    
    // Selector for making message read and deleting it from carousel
    func deleteMessage(timer: NSTimer){
        
        // Checks if message is openened or not
        if(!self.messageIsOpenend){
            
            // Check if index is empty or not for bounds of array
            if(!self.deleteditemIndexes.isEmpty){
                isAppending = true
                let type = timer.userInfo as String // Convert timer to String
                var carouselItemIndex = self.deleteditemIndexes.first?.toInt() // Getting first item from the array
                self.deleteditemIndexes.removeAtIndex(0) // Delete it
                var messageID = self.items[carouselItemIndex!].getID() // Get the messageID for JSON array  --> Gaat hier fout
                
                var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/confirm?messageId=" + String(messageID) + "&type=" + type
                DataManager.checkMessageRead(url){(codeFromJSON) in
                    
                    if(codeFromJSON == "200"){
                        
                        self.carousel.reloadData()
                        
                    }
                    
                }
                if(self.items[carouselItemIndex!].getType() == "1"){
                    self.messagesCount--
                }
                else{
                    self.newsCount--
                }
                self.items.removeAtIndex(carouselItemIndex!)
                self.carousel.removeItemAtIndex(carouselItemIndex!, animated: true)
                self.removeImage(carouselItemIndex!)
                //self.carousel.scrollToItemAtIndex(carouselItemIndex!, animated: false)
                
                if(self.items.isEmpty){
                    self.speech.speechString("U heeft geen berichten op dit moment")
                }
            }
        }
    }
}


