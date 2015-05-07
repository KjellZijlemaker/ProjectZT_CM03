
//
//  ViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, carouselDelegate, iCarouselDataSource, iCarouselDelegate, deleteMessageItem, messageOpenend
{
    //# MARK: - Array for all the items / settings to be loaded inside the carousel
    var pictures: [UIImage!] = []
    
    //# MARK: - Counters for the amount of messages and news
    var firstItem: Bool = true
    var messagesCount = 0
    var newsCount = 0
    var clubNewsCount = 0
    
    //# MARK: - Variables for adding new items to the array
    var totalNewItems = 0 // For total of new items (Non realtime appended)
    
    //# MARK: - Variables for appending messages / news
    var appendedMessages: [Item] = []
    
    // For checking if data is appending or not. Important for playing the speech or not inside the view,
    // when reloading the carousel!
    var isAppending = false
    var indexBeginningNewMessages = 0 // Index when the new messages appended (for counting down the new items in notification)
    var indexBeginningNewNews = 0 // Index when the new news appended (for counting down the new items in notification)
    var indexBeginningNewClubNews = 0 // Index when the new clubNews appended
    
    
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
    
    var appendDataTimer = NSTimer() // Timer for appendign data
    var checkAppendingTimer = NSTimer() // Timer for checking if append timer is needed
    
    //# MARK: custom Views
    var notificationDot: NotificationDot!
    var notificationText: NotificationText!
    
    //# MARK: Models
    var items: [Item] = []
    var userSettings: Settings = Settings() // For getting all the settings from user
    var token: Token = Token()
    
    //# MARK: Managers
    let timerManager = TimerManager() // For time
    
    //# MARK: Helpers
    var carouselSpeechHelper = CarouselSpeechHelper()
    
    // sounds
    var notificationSound = SoundManager(resourcePath: "Roekoe", fileType: "m4a") // For the sounds
    var carouselEndSound = SoundManager(resourcePath: "CarouselEnding", fileType: "m4a") // For the sounds
    
    //# MARK: - Outlets for displaying labels / carousel
    @IBOutlet var carousel : iCarousel!
    @IBOutlet weak var categoryView: CategoryTypeView!
    
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
            getUserSettings(self.token.getToken(), updateSettings: false)
            
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
        self.carouselSpeechHelper.delegate = self
        
        let logoutButton = LogoutButton().showLogoutButton()
        self.view.addSubview(logoutButton)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "logoutButtonAction:")
        logoutButton.addGestureRecognizer(longPressRecognizer)
        
        
        // Setting up the views and other misc
        // Setup the notification text view
        self.notificationText = NotificationText()
        self.notificationText.makeNotificationTextView()
        self.view.addSubview(self.notificationText.getNotificationTextView())
        
        
        // Making dot animation for new item
        self.notificationDot = NotificationDot()
        self.notificationDot.makeDotView()
        self.notificationDot.hideDotView()
        self.view.addSubview(self.notificationDot.getDotView())
        
        self.categoryView.backgroundColor = UIColor.whiteColor()
        
        
        //# MARK: - Gesture methods
        //=============================================================================================
        
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
        
        self.setupBackgroundForegroundInit()
        self.setupAppendingTimer() // Timer for checking new items may execute
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
    
    // Motion gesture
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            self.getUserSettings(self.token.getToken(), updateSettings: true)
            if(self.userSettings.isNotificationSoundEnabled()){
                self.carouselSpeechHelper.getSpeech().speechString("Instellingen bijgewerkt")
            }
        }
    }
    
    //# MARK: - Gesture control methods
    //=================================================================================================
    
    //------------Dubble tap method for opening new view--------------//
    func singleTapped(){
        
        if(!self.items.isEmpty){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            
            switch self.items[self.carousel.currentItemIndex].getType(){
            case "1":
                // For performing the seque inside the storyboard
                performSegueWithIdentifier("showMessageContent", sender: self)
                println("message")
            case "2":
                performSegueWithIdentifier("showNewsMessageContent", sender: self)
                println("news")
            case "3":
                performSegueWithIdentifier("showClubNewsContent", sender: self)
            default:
                // For performing the seque inside the storyboard
                performSegueWithIdentifier("showMessageContent", sender: self)
            }
        }
    }
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        if(!self.items.isEmpty){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.carousel.scrollByNumberOfItems(-1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
        // Last item has been reached
        if(self.carousel.currentItemIndex == 0){
            self.carouselEndSound.playSound()
        }
        // Remove the dot when present
        if(self.notificationDot.isAnimating()){
            self.notificationText.removeNotificationTextFromView() // Remove from view
            self.notificationDot.getDotView().stopAnimating()
            
            // Hide it instead of removing view, otherwise txtView won't re appear
            self.notificationDot.hideDotView()
            
        }
        
    }
    
    //------------Swipe method to the left--------------//
    func leftSwiped(){
        if(!self.items.isEmpty){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.carousel.scrollByNumberOfItems(1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
        // Last item has been reached
        if(self.carousel.currentItemIndex == self.carousel.numberOfItems-1){
            self.carouselEndSound.playSound()
        }
        // Remove the dot when present
        if(self.notificationDot.isAnimating()){
            self.notificationText.removeNotificationTextFromView() // Remove from view
            self.notificationDot.getDotView().stopAnimating()
            
            // Hide it instead of removing view, otherwise txtView won't re appear
            self.notificationDot.hideDotView()
            
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
    
    
    //# MARK: - Setting up the backround and foreground notifications
    func setupBackgroundForegroundInit(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"totalNewItemsToForeground", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    
    //# MARK: - Setting up the timer(s)
    
    func setupAppendingTimer(){
        self.checkAppendingTimer = NSTimer.scheduledTimerWithTimeInterval(13.0, target:self, selector: Selector("checkAppendingTimerSelectorHelper"), userInfo: nil, repeats: true)
    }
    
    func setupAppendDataTimer(type: String){
        self.appendDataTimer = NSTimer.scheduledTimerWithTimeInterval(8.0, target:self, selector: Selector("appendDataTimerSelectorHelper:"), userInfo: type, repeats: true)
    }
    
    
    //# MARK: - Selectors for the timers
    
    // For checking if checking for appending should execute
    func checkAppendingTimerSelectorHelper(){
        // If there are no items of one of the categories, setup timer and append in sequences
        if(self.messagesCount == 0 && self.clubNewsCount == 0 || self.newsCount == 0 ){
            
            if(!self.appendDataTimer.valid){
                println("NO MESSAGES, CLUBS OR NEWS")
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit() || self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("0")
                }
                
            }
            else{
                println("NO MESSAGES, CLUBS OR NEWS")
                self.deleteTimer(self.appendDataTimer)
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit() || self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("0")
                }
            }
        }
            
        else if(self.messagesCount == 0){
            if(!self.appendDataTimer.valid){
                println("NO MESSAGES")
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.setupAppendDataTimer("1")
                }
            }
            else{
                println("NO MESSAGES")
                self.deleteTimer(self.appendDataTimer)
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.setupAppendDataTimer("1")
                }
            }
        }
        else if(self.newsCount == 0){
            if(!self.appendDataTimer.valid){
                println("NO NEWS")
                if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("2")
                }
            }
            else{
                println("NO NEWS")
                self.deleteTimer(self.appendDataTimer)
                if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("2")
                }            }
        }
        else if(self.clubNewsCount == 0){
            if(!self.appendDataTimer.valid){
                println("NO CLUBS")
                self.setupAppendDataTimer("3")
                
            }
            else{
                println("NO CLUBS")
                self.deleteTimer(self.appendDataTimer)
                self.setupAppendDataTimer("3")
            }
        }
        else{
            if(self.appendDataTimer.valid){
                self.deleteTimer(self.appendDataTimer)
                
            }
        }
    }
    
    // Selector for appending the data
    func appendDataTimerSelectorHelper(timer: NSTimer){
        var type = timer.userInfo as String
        self.appendAppData(type, showLoadingScreen: false)
    }
    
    // Deleting the timer
    func deleteTimer(timer: NSTimer){
        timer.invalidate()
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
            label.frame = CGRectMake(-206, -250, 612, 120);
            label.backgroundColor = UIColor.whiteColor()
            label.numberOfLines = 2
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(45)
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
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(self.items[index].getSubject())"
        (view as UIImageView!).image = self.pictures[index]
        
        return view
    }
    
    // Checking for new items to append
    func carouselCheckForAppendingItems(){
        
        // If the number is lower then two there will no appending in the carousel, but items will be decremented for array
        if(self.carousel.numberOfItems >= 2){
            
            // self.deleteTimer(self.appendDataTimer) // Delete old timer before making new one
            
            if (self.carousel.currentItemIndex == self.messagesCount-1){
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.appendAppData("1", showLoadingScreen: true)
                }
            }
            else if (self.carousel.currentItemIndex == self.messagesCount + self.clubNewsCount + self.newsCount-1) {
                if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.appendAppData("2", showLoadingScreen: true)
                }
            }
            else if(self.carousel.currentItemIndex == self.messagesCount + self.clubNewsCount-1){
                self.appendAppData("3", showLoadingScreen: true)
            }
        }
            
        else{
            if(self.carousel.currentItemIndex == self.carousel.numberOfItems - self.totalNewItems && self.totalNewItems > 0){
                self.notificationDot.showDotView() // Show dot
                self.notificationText.hideNotificationTextView() // New items, so unhide textView
                
                self.totalNewItems--
            }
        }
    }
    
    // Function for checking if the index from the carousel changed
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!){
        
        self.carouselCheckForAppendingItems() // Check for appending items and decrement notification counter if needed
        
        if(!self.items.isEmpty){
            // Setting category per item inside the array
            self.setCategoryType(self.carousel.currentItemIndex, isEmpty: false) // Setting the category type
        }
        else{
            // Setting category per item inside the array
            self.setCategoryType(self.carousel.currentItemIndex, isEmpty: true) // Setting the category type
            self.carouselSpeechHelper.speechNoItemsAvailable()
        }
        
        
        
        if(!self.isAppending){
            // Speech the item
            self.carouselSpeechHelper.carouselSpeechItem()
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
            
        case "3":
            pictures.append(UIImage(named:"corp.jpg"))
        default:
            pictures.append(UIImage(named:"message.jpg"))
            
        }
        
    }
    
    // Appending the image per index inside the carousel
    func appendImage(index: Int){
        switch(self.items[index].getType()){
            
        case "1":
            pictures.insert(UIImage(named:"message.jpg"), atIndex: index)
            println(index)
        case "2":
            pictures.insert(UIImage(named:"news.jpg"), atIndex: index)
            println(index)
        case "3":
            pictures.insert(UIImage(named:"corp.jpg"), atIndex: index)
        default:
            pictures.insert(UIImage(named:"message.jpg"), atIndex: index)
            
        }
        
    }
    
    // Removing the image at index
    func removeImage(index:Int ){
        self.pictures.removeAtIndex(index)
        
    }
    
    // Set the type of category and show it inside the categoryView
    func setCategoryType(index: Int, isEmpty: Bool){
        var isHello = true
        
        if(!isEmpty){
            switch(self.items[index].getType()){
                
            case "1":
                self.categoryView.setCategoryTypeLabel("Persoonlijk bericht")
                if(self.items[index].getCategory() != ""){
                    self.categoryView.setCategoryTypeCategoryViewLabel(self.items[index].getCategory())
                }
                else{
                    self.categoryView.setCategoryTypeCategoryViewLabel("")
                }
                self.categoryView.nextItemAnimate(UIColor.greenColor())
                
            case "2":
                self.categoryView.setCategoryTypeLabel("Nieuwsbericht")
                if(self.items[index].getCategory() != ""){
                    self.categoryView.setCategoryTypeCategoryViewLabel(self.items[index].getCategory())
                }
                else{
                    self.categoryView.setCategoryTypeCategoryViewLabel("")
                }
                self.categoryView.nextItemAnimate(UIColor.yellowColor())
                
            case "3":
                self.categoryView.setCategoryTypeLabel("Nieuwsbrief")
                if(self.items[index].getCategory() != ""){
                    self.categoryView.setCategoryTypeCategoryViewLabel(self.items[index].getCategory())
                }
                else{
                    self.categoryView.setCategoryTypeCategoryViewLabel("")
                }
                self.categoryView.nextItemAnimate(UIColor.orangeColor())
                
                
            default:
                self.categoryView.setCategoryTypeLabel("Geen berichten")
                if(self.items[index].getCategory() != ""){
                    self.categoryView.setCategoryTypeCategoryViewLabel(self.items[index].getCategory())
                }
                else{
                    self.categoryView.setCategoryTypeCategoryViewLabel("")
                }
                self.categoryView.nextItemAnimate(UIColor.blueColor())
                break
                
            }
        }
            
        else{
            self.categoryView.setCategoryTypeLabel("Geen berichten")
            self.categoryView.nextItemAnimate(UIColor.yellowColor())
        }
        
    }
    
    //# MARK: - Buttons
    //=================================================================================================
    
    func logoutButtonAction(sender: UILongPressGestureRecognizer) {
        self.carouselSpeechHelper.getSpeech().stopSpeech()
        if sender.state == UIGestureRecognizerState.Began
        {
            var alert = self.setAlertView("Let op", message: "Weet u zeker dat u wilt uitloggen?")
            alert.addButtonWithTitle("Ja", type: SIAlertViewButtonType.Default, handler:{ (ACTION :SIAlertView!)in
                self.goToLogin()
            })
            alert.addButtonWithTitle("Nee", type: SIAlertViewButtonType.Cancel, handler: nil)
            alert.show()
        }
    }
    
    // Function for going to the login phase
    func goToLogin(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            
        });
        
        // Invalidate timer if present
        if(self.checkAppendingTimer.valid){
            self.checkAppendingTimer.invalidate() // Invalidate the timer
        }
        // Invalidate timer if present
        if(self.appendDataTimer.valid){
            self.appendDataTimer.invalidate() // Invalidate the timer
        }
        
        // Remove the keys if present
        if(self.defaults.objectForKey("token") != nil && self.defaults.objectForKey("refreshToken") != nil){
            
            self.defaults.removeObjectForKey("token")
            self.defaults.removeObjectForKey("refreshToken")
        }
        
        self.performSegueWithIdentifier("showLogin", sender: self) // Go to the login screen
    }
    
    
    //# MARK: - Alerts
    //=================================================================================================
    
    // For loading screen
    func setLoadingView(title: String){
        // Notification for getting items
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = title
    }
    
    // Setting alertView for notification user
    func setAlertView(title: String, message: String) -> SIAlertView{
        var alert:SIAlertView  = SIAlertView(title: title, andMessage: message)
        alert.titleFont = UIFont(name: "Verdana", size: 30)
        alert.messageFont = UIFont(name: "Verdana", size: 26)
        alert.buttonFont = UIFont(name: "Verdana", size: 30)
        alert.transitionStyle = SIAlertViewTransitionStyle.Bounce
        
        return alert
    }
    
    //# MARK: - UIBackground / Foreground methods
    //=================================================================================================
    func totalNewItemsToForeground(){
        var itemsIndexArray = [Int]()
        
        // Getting the date
        var dateFormatter = NSDateFormatter()
        var date = NSDate()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var currentdateString = dateFormatter.stringFromDate(date)
        currentdateString.substringToIndex(advance(currentdateString.startIndex, 10)) // Getting only the year, month day
        
        for i in 0...self.items.count-1{

                println(self.items[i].getPublishDate())
                var publishedDateString = self.items[i].getPublishDate()
                println(publishedDateString)
                
                if(currentdateString != publishedDateString){
                    for o in 0...self.items.count-1{
                        if(self.items[i].getID() == self.items[o].getID()){
                            self.carousel.removeItemAtIndex(i, animated: false) // From carousel
                            if(self.items[i].getType() == "1"){
                                self.messagesCount--
                            }
                            else if(self.items[i].getType() == "2"){
                                self.newsCount--
                            }
                            else if(self.items[i].getType() == "3"){
                                self.clubNewsCount--
                            }
                            itemsIndexArray.append(i)
                        }
                    }
                }
            }
        println(self.items.count-1)
        println(itemsIndexArray)
        
        if(!itemsIndexArray.isEmpty){
            for j in reverse(0...itemsIndexArray.count-1){
                self.items.removeAtIndex(itemsIndexArray[j])
                self.removeImage(itemsIndexArray[j])
            }
        }
        println(self.items.count)
        println("NIEUWS" + String(self.newsCount))
        println("CLUB" + String(self.clubNewsCount))

        // If there are no more items,
        if(self.items.isEmpty){
            self.firstItem = true
        }
        
       self.carousel.reloadData()
        
        if(self.items.isEmpty){
            self.carouselCurrentItemIndexDidChange(self.carousel)
        }
        
        if(totalNewItems >= 0){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            //            self.newItemsToSpeech(self.totalNewItems, "0")
            //            self.carousel.scrollToItemAtIndex(self.items.count-1-self.totalNewItems, animated: true) // Scroll to the section of last items
        }
        
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
            vc.speech = self.carouselSpeechHelper.getSpeech()
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.messageIsOpenend = true
        }
        if segue.identifier == "showNewsMessageContent"{
            let vc = segue.destinationViewController as NewsMessageViewController
            vc.deletingMessage = self
            vc.openendMessage = self
            vc.delegate = self
            vc.news = self.items[self.carousel.currentItemIndex]
            vc.userSettings = self.userSettings
            vc.speech = self.carouselSpeechHelper.getSpeech()
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.messageIsOpenend = true
        }
        if segue.identifier == "showClubNewsContent"{
            let vc = segue.destinationViewController as ClubNewsViewController
            vc.deletingMessage = self
            vc.openendMessage = self
            vc.delegate = self
            vc.clubNews = self.items[self.carousel.currentItemIndex]
            vc.userSettings = self.userSettings
            vc.speech = self.carouselSpeechHelper.getSpeech()
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.messageIsOpenend = true
        }
        if segue.identifier == "showLogin"{
            let vc = segue.destinationViewController as LoginViewController
        }
        
    }
    
    
    //# MARK: - User data methods
    //=================================================================================================
    
    // Function for getting the main app data and filling it into the array
    func getUserSettings(tokenKey: String, updateSettings: Bool){
        
        var url = "http://84.107.107.169:8080/VisioWebApp/API/clientSettings?tokenKey=" + tokenKey
        
        UserManager.getUserSettings(url){(settings) in
            
            // If the setting has a return code of 200, all went OK
            if(settings.getReturnCode() == "200"){
                
                // Transfering array to global array
                self.userSettings = settings
                
                // If the background is white, the carousel should be black. Otherwise
                // the contrast is too weak
                if(self.userSettings.getSecondaryColorType() == "FFFFFF"){
                    // Setting the color and backround
                    self.carousel.backgroundColor = ColorHelper.UIColorFromRGB("000000")
                }
                else{
                    // Setting the color and backround
                    self.carousel.backgroundColor = ColorHelper.UIColorFromRGB(self.userSettings.getSecondaryColorType())
                }
                
                // Execute only when getting settings for the first time
                if(!updateSettings){
                    self.token.hasRefreshToken(true) // For getting the messages
 
                    // Getting the app data and fill it in the global array
                    self.getAppData(self.token.getToken())
                }

                
            }
            else if(settings.getReturnCode() == "400"){
                if(self.token.isRefreshToken()){
                    self.token.hasRefreshToken(false)
                    self.getUserSettings("http://84.107.107.169:8080/VisioWebApp/API/clientSettings?tokenKey=" + self.token.getRefreshToken(), updateSettings: false)
                }
                else{
                    // Send user back to login phase
                    self.goToLogin()
                }
            }
            else{
                var alert = self.setAlertView("Probleem", message: "Kon instellingen niet ophalen")
                alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler:{ (ACTION :SIAlertView!)in
                    
                    // Send user back to login phase
                    self.goToLogin()
                })
                alert.show()
            }
        }
        
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
                        else if(items[i].getType() == "2"){
                            self.newsCount++
                            self.items.append(items[i])
                            
                            // Setting the right images for each category
                            self.setImages(i)
                            
                            self.carousel.insertItemAtIndex(i, animated: true) // Insert items at last index
                            if(self.newsCount == self.userSettings.getNewsMessageLimit()){
                                break
                            }
                        }
                        else if(items[i].getType() == "3"){
                            self.clubNewsCount++
                            self.items.append(items[i])
                            
                            // Setting the right images for each category
                            self.setImages(i)
                            
                            self.carousel.insertItemAtIndex(i, animated: true) // Insert items at last index
                            
                        }
                    }
                    
                    if(self.userSettings.isSpeechEnabled()){
                        // Seepching total of items
                        self.carouselSpeechHelper.getSpeech().speechString("U heeft in totaal: " + String(self.messagesCount) + " nieuwe berichten, " + String(self.clubNewsCount) + " nieuwe nieuwsbrieven, en " + String(self.newsCount) + " nieuwe nieuwsberichten")
                    }
                    
                    // Check if carousel has items, if not, there is no first item and method should not be executed
                    if(!self.items.isEmpty){
                        if(self.firstItem){
                            self.carouselSpeechHelper.firstItemInCarousel() // Speeching the first item inside the carousel
                        }
                    }
                    
                    
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
                        var alert = self.setAlertView("Probleem", message: "Kon berichten niet ophalen")
                        alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler:{ (ACTION :SIAlertView!)in
                            
                            // Send user back to login phase
                            self.goToLogin()
                        })
                        alert.show()
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                        
                    }
                    
                }
            }
                
                // Else, there are no new items
            else{
                if(self.userSettings.isSpeechEnabled()){
                    self.carouselSpeechHelper.getSpeech().speechString("Er zijn geen berichten op dit moment")
                }
                else{
                    var alert = self.setAlertView("Melding", message: "Er zijn geen berichten op dit moment")
                    alert.addButtonWithTitle("OK", type: SIAlertViewButtonType.Default, handler:{ (ACTION :SIAlertView!)in
                        
                        // Send user back to login phase
                        self.goToLogin()
                    })
                    alert.show()
                }
                
                // If there are less then two items, call the timer
                if(self.carousel.numberOfItems < 2){
                    
                    self.categoryView.hidden = false // Unhide view
                    self.setCategoryType(0, isEmpty: true) // Show the category
                }
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
            }
        }
    }
    
    
    
    // Function for appending app data, only and only if the number of items is greater then 1. This is for getting the new items only when at the end of the carousel
    func appendAppData(type: String, showLoadingScreen: Bool){
        if(!self.messageIsOpenend){
            var oldID = "0" // When there are no items in carousel, there is no old ID
            
            if(!self.firstItem){
                oldID = self.items[self.carousel.currentItemIndex].getID()
            }
            
            var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token.getToken() // URL for JSON
            
            // Show loading screen if set to true
            if(showLoadingScreen){
                self.setLoadingView("Nieuwe berichten laden")
            }
            DataManager.getItems(url){(items) in
                
                // If not empty, enable appending data
                if(!items.isEmpty && items[0].getReturnCode() == "200"){
                    
                    var idArrayOld: [Int] = []
                    var idArrayNew: [Int] = []
                    var newIDArray: [Int] = []
                    var newArray: [AnyObject] = []
                    
                    // Getting all the ID's for new ID array
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
                    
                    if(!self.items.isEmpty){
                        // Getting all the ID's for old ID array
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
                    
                    
                    // Making sets
                    var set1 = NSMutableSet(array: idArrayOld)
                    var set2 = NSMutableSet(array: idArrayNew)
                    
                    // Getting only the new ID's
                    set2.minusSet(set1)
                    
                    // Putting it into a new array
                    newArray = set2.allObjects
                    
                    // Append all the newID's to the new array
                    if(!newArray.isEmpty){
                        for k in 0...newArray.count-1{
                            newIDArray.append(newArray[k] as Int)
                        }
                    }
                    
                    // Looping through the array to look for new items to append
                    if(newIDArray.count != 0){
                        
                        // Setting the count of new items
                        var newMessages = 0
                        var newNews = 0
                        var newClubNews = 0
                        
                        var indexHasChanged = false
                        
                        for l in 0...items.count-1{
                            
                            for k in 0...newIDArray.count-1{
                                
                                // Found new item
                                if(items[l].getID().toInt() == newIDArray[k]){
                                    self.isAppending = true // Now appending data, so speech may not execute
                                    
                                    // Check the type and append
                                    if(items[l].getType() == "1"){
                                        println("ISONE")
                                        if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                                            indexHasChanged = true // New item may append
                                            
                                            self.items.insert(items[l], atIndex: self.messagesCount)
                                            
                                            self.appendImage(self.messagesCount)
                                            self.carousel.insertItemAtIndex(self.messagesCount, animated: true)
                                            
                                            //Add the amount of messages or news
                                            self.messagesCount++
                                            newMessages++
                                        }
                                        else{
                                            break
                                        }
                                    }
                                    else if(items[l].getType() == "2"){
                                        if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                                            
                                            indexHasChanged = true
                                            
                                            var indexNewsCount = self.messagesCount + self.clubNewsCount + self.newsCount
                                            self.items.insert(items[l], atIndex: indexNewsCount)
                                            self.appendImage(indexNewsCount)
                                            self.carousel.insertItemAtIndex(indexNewsCount, animated: true)
                                            
                                            //Add the amount of messages or news
                                            newNews++
                                            self.newsCount++
                                            
                                        }
                                        else{
                                            break
                                        }
                                    }
                                    else if(items[l].getType() == "3"){
                                        
                                        indexHasChanged = true
                                        
                                        var indexClubNewsCount = self.messagesCount + self.clubNewsCount
                                        self.items.insert(items[l], atIndex: indexClubNewsCount)
                                        self.appendImage(indexClubNewsCount)
                                        self.carousel.insertItemAtIndex(indexClubNewsCount, animated: true)
                                        
                                        //Add the amount of messages or news
                                        newClubNews++
                                        self.clubNewsCount++
                                        
                                    }
                                }
                                
                            }
                        }
                        
                        // Function for show the notification in case of Message or news
                        func showNotification(totalNewItems: Int){
                            // If the animation is not already active, start it
                            if(!self.notificationDot.getDotView().isAnimating()){
                                self.notificationDot.getDotView().startAnimating()
                                self.notificationDot.getDotView().addSubview(self.notificationText.getNotificationTextView())
                            }
                            
                            self.totalNewItems++ // Append the number of items
                            self.notificationText.setNotificationTextView(String(totalNewItems)) // Update the text
                            self.notificationText.showNotificationTextView()
                            println("SHOWDOT")
                            self.notificationDot.showDotView() // Show dot
                        }
                        
                        
                        if(newMessages != 0){
                            // Show notification if loading screen is set to true
                            if(showLoadingScreen){
                                showNotification(newMessages)
                            }
                        }
                        else if(newClubNews != 0){
                            // Show notification if loading screen is set to true
                            if(showLoadingScreen){
                                showNotification(newClubNews)
                            }
                        }
                        else if(newNews != 0){
                            // Show notification if loading screen is set to true
                            if(showLoadingScreen){
                                showNotification(newNews)
                            }
                        }
                        
                        
                        // Check if carousel has items
                        if(!self.items.isEmpty){
                            if(self.firstItem){
                                self.carouselSpeechHelper.firstItemInCarousel() // Speeching the first item inside the carousel
                            }
                        }
                        
                        // If the index has changed (appended item), speech the total of new items
                        if(indexHasChanged){
                            
                            // tell the total of new items
                            if(self.userSettings.isNotificationSoundEnabled()){
                                if(newMessages > 0){
                                    self.carouselSpeechHelper.newItemsToSpeech(newMessages, type: "1")
                                }
                                if(newNews > 0){
                                    self.carouselSpeechHelper.newItemsToSpeech(newNews, type: "2")
                                }
                                if(newClubNews > 0){
                                    self.carouselSpeechHelper.newItemsToSpeech(newClubNews, type: "3")
                                }
                                
                                if(self.userSettings.isNotificationSoundEnabled()){
                                    self.notificationSound.playSound() // Play the ROEKOE sound
                                    
                                }
                                self.carouselCurrentItemIndexDidChange(self.carousel) // Refresh the item
                                
                            }
                            
                            //Get back to the item carousel where the user was focussed on
                            for p in 0...self.items.count-1{
                                
                                // Old ID found, get back to it
                                if(oldID == self.items[p].getID()){
                                    println("FOUND")
                                    self.carousel.scrollToItemAtIndex(p, animated: false)
                                    self.carouselCurrentItemIndexDidChange(self.carousel) // Reload the view
                                    break
                                }
                                else{
                                    // Not found, at the ending change the index and set appending to false for speech
                                    println("NOT FOUND")
                                    if(p == self.items.count-1){
                                        self.isAppending = false
                                        self.carouselCurrentItemIndexDidChange(self.carousel) // Reload the view
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                // Close loading screen if set to false
                if(showLoadingScreen){
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                    
                }
            }
            
            
            // Setting new indexes for appending new items
            if(type == "1"){
                self.indexBeginningNewMessages = self.messagesCount-1 // Index when new items will begin to append
            }
            else if(type == "2"){
                self.indexBeginningNewNews = self.messagesCount + self.newsCount-1 // Index when new items will begin to append
            }
            else if(type == "3"){
                self.indexBeginningNewClubNews = self.messagesCount + self.newsCount + self.clubNewsCount-1 // Index when new items will begin to append
            }
            
            self.oldBoundaryBeginningNewItems = self.boundaryBeginningNewItems
            self.boundaryBeginningNewItems = self.indexBeginningNewMessages // Transfer to boundary for counting
            
        }
        
    }
    
    
    //# MARK: - Data deletion methods
    //=================================================================================================
    
    func executeDeletionTimer(carouselMessageNumber: String, _ type: String){
        var userInfoArray = Array<String>()
        userInfoArray.append(carouselMessageNumber)
        userInfoArray.append(type)
        
        // Getting the max seconds upon checking the type
        var interval:NSTimeInterval!
        if(type == "1"){
            interval = NSTimeInterval(self.userSettings.getMessagesStoreMaxSeconds().toInt()!)
        }
        else if(type == "2"){
            interval = NSTimeInterval(self.userSettings.getNewsStoreMaxSeconds().toInt()!)
        }
        else if(type == "3"){
            interval = NSTimeInterval(self.userSettings.getClubNewsStoreMaxSeconds().toInt()!)
        }
        var newTimer = timerManager.startTimer(self, selector: Selector("checkIDForDeletion:"), userInfo: userInfoArray, interval: interval) // Start timer
    }
    
    
    // Timer for deleting message. Is delegaded from NewsViewController
    func checkIDForDeletion(timer: NSTimer) {
        
        let userInfoArray = timer.userInfo as [String] // Convert timer to String
        
        // Look for ID
        for i in 0...self.items.count-1{
            
            if(self.items[i].getID() == userInfoArray[0]){
                self.deleteditemIndexes.append(String(i)) // Appending the carouselMessageNumber to the deleteditemIndex
                
                deleteMessage(userInfoArray[1])
                break
            }
        }
        
        
    }
    
    // Selector for making message read and deleting it from carousel
    func deleteMessage(type: String){
        
        // Check if index is empty or not for bounds of array
        if(!self.deleteditemIndexes.isEmpty){
            self.messageIsOpenend = false
            var oldID = self.items[self.carousel.currentItemIndex].getID()
            isAppending = true
            var carouselItemIndex = self.deleteditemIndexes.first?.toInt() // Getting first item from the array
            self.deleteditemIndexes.removeAtIndex(0) // Delete it
            var messageID = self.items[carouselItemIndex!].getID() // Get the messageID for JSON array  --> Gaat hier fout
            
            var url = "http://84.107.107.169:8080/VisioWebApp/API/chat/confirm?messageId=" + String(messageID) + "&type=" + type
            DataManager.checkMessageRead(url){(codeFromJSON) in
                
                if(codeFromJSON == "200"){
                    
                    // Checking what kind of message was deleted
                    if(self.items[carouselItemIndex!].getType() == "1"){
                        self.messagesCount--
                    }
                    else if(self.items[carouselItemIndex!].getType() == "2"){
                        self.newsCount--
                    }
                    else if(self.items[carouselItemIndex!].getType() == "3"){
                        self.clubNewsCount--
                    }
                    println("Deleting..." + String(carouselItemIndex!))
                    self.items.removeAtIndex(carouselItemIndex!) // Remove it
                    self.carousel.removeItemAtIndex(carouselItemIndex!, animated: true) // From carousel
                    self.removeImage(carouselItemIndex!) // Remove the image
                    
                    // Speech if empty
                    if(self.items.isEmpty){
                        if(self.userSettings.isSpeechEnabled()){
                            self.carouselSpeechHelper.getSpeech().speechString("U heeft geen berichten op dit moment")
                        }
                    }
                    
                    //Get back to the item carousel where the user was focussed on
                    for p in 0...self.items.count-1{
                        
                        // Found the old ID, go back to it
                        if(oldID == self.items[p].getID()){
                            println("FOUND")
                            self.carousel.scrollToItemAtIndex(p, animated: false)
                            self.carouselCurrentItemIndexDidChange(self.carousel) // Reload the view
                            break
                        }
                        else{
                            // Not found, at the ending change the index and set appending to false for speech
                            println("NOT FOUND")
                            if(p == self.items.count-1){
                                self.isAppending = false
                                self.carouselCurrentItemIndexDidChange(self.carousel) // Reload the view
                            }
                        }
                    }
                }
                
            }
            
        }
    }
}
