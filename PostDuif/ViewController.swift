
//
//  ViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, carouselDelegate, iCarouselDataSource, iCarouselDelegate, deleteMessageItem, messageOpenend, userManagerDelegate, dataManagerDelegate
{
    //var keychain = Keychain(service: "com.visio.postduif")
    let backEndServerAddress = "84.107.107.169" // This is the address of the server. Must be changed if needed
    
    //# MARK: - Array for all the items / settings to be loaded inside the carousel
    var pictures: [UIImage!] = []
    
    //# MARK: - Counters for the carousel
    var messagesCount = 0 // For total of new messages
    var newsCount = 0 // For total of new news
    var clubNewsCount = 0 // For total of new clubnews
    
    //# MARK: - Booleans (checks) for carousel
    var firstItem: Bool = true // To indicate if this is the first item of carousel
    var isAppending = false // For checking if data is appending or not. Important for playing the speech or not inside the view, when reloading the carousel!
    var messageIsOpenend: Bool = false // Checking if message has openend, so not the same item will be removed
    
    //# MARK: - Arrays for the items and deleted items
    var items: [Item] = [] // Items inside the carousel
    var deleteditemIndexes:[String] = [] // Carousel indexes for deleting (user read)
    
    //# MARK: - Timers for appending new items to carousel
    var appendDataTimer = NSTimer() // Timer for appending data
    var checkAppendingTimer = NSTimer() // Timer for checking if append timer is needed
    
    //# MARK: custom Views
    var notificationDot: NotificationDot!
    var notificationText: NotificationText!
    
    //# MARK: Models
    var userSettings: Settings = Settings() // For getting all the settings from user
    var token: Token = Token()
    
    //# MARK: Helpers for Carousel
    var carouselSpeechHelper: CarouselSpeechHelper!
    
    //# MARK: Sounds for inside the Carousel
    var notificationSound = SoundManager(resourcePath: "Roekoe", fileType: "m4a") // For the sounds
    var carouselEndSound = SoundManager(resourcePath: "CarouselEnding", fileType: "m4a") // For the sounds
    
    //# MARK: MISC
    var passToLogin: Bool = false // Pass to login when the Token is not valid
    let defaults = NSUserDefaults.standardUserDefaults() // The location of the Token
    
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
        UIApplication.sharedApplication().idleTimerDisabled = true // Disable the timer to lock screen
        
        // Setting inital settings for swipe gestures
        self.carousel.userInteractionEnabled = true
        self.carousel.delegate = self
        self.carousel.type = .Custom
        self.carousel.scrollEnabled = false
        self.carousel.isAccessibilityElement = false
        
        // Setting up the logout button
        let logoutButton = LogoutButton().showLogoutButton()
        logoutButton.isAccessibilityElement = false
        self.view.addSubview(logoutButton)
        
        // Setting the button long press
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
        self.categoryView.isAccessibilityElement = true
        
        
        //# MARK: - Gesture methods
        //=============================================================================================
        
        //------------right  swipe gesture in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        //-----------left swipe gesture in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        //-----------single tap gesture in view--------------//
        let singleTap = UITapGestureRecognizer(target: self, action:Selector("singleTapped"))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }
    
    
    // Only when the keys are empty!!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
        // If the keys were empty
        if(passToLogin){
            
            // Sending user back to login phase
            self.goToLogin()
        }
    }
    
    // Statusbar style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Motion gesture
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if(!self.messageIsOpenend){
            if (motion == .MotionShake) {
                self.getUserSettings(self.token.getToken(), updateSettings: true)
            }
        }
    }
    
    //# MARK: - Gesture control methods
    //=================================================================================================
    
    /**
    Selector for opening new view when tapped on the item
    */
    func singleTapped(){
        
        if(!self.items.isEmpty){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            
            // Switch for performing the seque when tapped on item. Will also set a boolean for checking that the message is read
            switch self.items[self.carousel.currentItemIndex].getType(){
            case "1":
                self.items[self.carousel.currentItemIndex].hasRead(true)
                performSegueWithIdentifier("showMessageContent", sender: self)
            case "2":
                self.items[self.carousel.currentItemIndex].hasRead(true)
                performSegueWithIdentifier("showNewsMessageContent", sender: self)
            case "3":
                self.items[self.carousel.currentItemIndex].hasRead(true)
                performSegueWithIdentifier("showClubNewsContent", sender: self)
            default:
                self.items[self.carousel.currentItemIndex].hasRead(true)
                performSegueWithIdentifier("showMessageContent", sender: self)
            }
        }
    }
    
    /**
    Selector for opening new view when swiped to the right
    */
    func rightSwiped(){
        if(!self.items.isEmpty){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.carousel.scrollByNumberOfItems(-1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
        // Last item has been reached
        if(self.carousel.currentItemIndex == 0){
            if(self.userSettings.isEndOfMessageSoundEffectEnabled()){
                self.carouselEndSound.playSound()
            }
        }
        // Remove the dot when present
        if(self.notificationDot.isAnimating()){
            self.notificationText.removeNotificationTextFromView() // Remove from view
            self.notificationDot.getDotView().stopAnimating()
            
            // Hide it instead of removing view, otherwise txtView won't re appear
            self.notificationDot.hideDotView()
            
        }
        
    }
    
    /**
    Selector for opening new view when swiped to the left
    */
    func leftSwiped(){
        if(!self.items.isEmpty){
            self.carouselSpeechHelper.getSpeech().stopSpeech()
            self.carousel.scrollByNumberOfItems(1, duration: 0.35)
            self.isAppending = false // Not appending, but swiping
        }
        // Last item has been reached
        if(self.carousel.currentItemIndex == self.carousel.numberOfItems-1){
            if(self.userSettings.isEndOfMessageSoundEffectEnabled()){
                self.carouselEndSound.playSound()
            }
        }
        // Remove the dot when present
        if(self.notificationDot.isAnimating()){
            self.notificationText.removeNotificationTextFromView() // Remove from view
            self.notificationDot.getDotView().stopAnimating()
            
            // Hide it instead of removing view, otherwise txtView won't re appear
            self.notificationDot.hideDotView()
            
        }
    }
    
    // When scrolling with Voice Over on, three vinger swipes will be available
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if(!self.messageIsOpenend){
            if (direction == UIAccessibilityScrollDirection.Right) {
                self.rightSwiped()
            }
            else if (direction == UIAccessibilityScrollDirection.Left) {
                self.leftSwiped()
            }
            
            UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        }
        return true
    }
    
    
    //# MARK: - Setting up the observers
    /**
    Function for setting up the observers for coming from the background or going to the foreground
    */
    func setupBackgroundForegroundInit(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"deleteAndSpeechItemsToForeground", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopSpeechItemsToBackground:"), name:UIApplicationDidEnterBackgroundNotification, object: nil)
        
    }
    
    
    //# MARK: - Setting up the timer(s)
    /**
    Function for setting up the timer for checking if items should be appended
    */
    func setupAppendingTimer(){
        self.checkAppendingTimer = NSTimer.scheduledTimerWithTimeInterval(13.0, target:self, selector: Selector("checkAppendingTimerSelectorHelper"), userInfo: nil, repeats: true)
    }
    
    /**
    Function for setting up the timer to append the items in a timely manner
    */
    func setupAppendDataTimer(type: String){
        self.appendDataTimer = NSTimer.scheduledTimerWithTimeInterval(8.0, target:self, selector: Selector("appendDataTimerSelectorHelper:"), userInfo: type, repeats: true)
    }
    
    
    //# MARK: - Selectors for the timers
    
    /**
    Selector for checking if the items should be appended
    */
    func checkAppendingTimerSelectorHelper(){
        // If there are no items of one of the categories, setup timer and append in sequences
        if(self.messagesCount == 0 && self.clubNewsCount == 0 || self.newsCount == 0 ){
            
            if(!self.appendDataTimer.valid){
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit() || self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("0")
                }
                
            }
            else{
                self.deleteTimer(self.appendDataTimer)
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit() || self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("0")
                }
            }
        }
            
        else if(self.messagesCount == 0){
            if(!self.appendDataTimer.valid){
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.setupAppendDataTimer("1")
                }
            }
            else{
                self.deleteTimer(self.appendDataTimer)
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.setupAppendDataTimer("1")
                }
            }
        }
        else if(self.newsCount == 0){
            if(!self.appendDataTimer.valid){
                if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("2")
                }
            }
            else{
                self.deleteTimer(self.appendDataTimer)
                if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.setupAppendDataTimer("2")
                }
            }
        }
        else if(self.clubNewsCount == 0){
            if(!self.appendDataTimer.valid){
                if(self.clubNewsCount < self.userSettings.getClubNewsMessageLimit()){
                    self.setupAppendDataTimer("3")
                }
            }
            else{
                self.deleteTimer(self.appendDataTimer)
                if(self.clubNewsCount < self.userSettings.getClubNewsMessageLimit()){
                    self.setupAppendDataTimer("3")
                }
            }
        }
        else if(self.messagesCount != 0){
            if(!self.appendDataTimer.valid){
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.setupAppendDataTimer("1")
                }
            }
            else{
                self.deleteTimer(self.appendDataTimer)
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.setupAppendDataTimer("1")
                }
            }
            
        }
        else{
            if(self.appendDataTimer.valid){
                self.deleteTimer(self.appendDataTimer)
                
            }
        }
    }
    
    /**
    Selector for appending the item
    :param: The timer where the needed information is in
    */
    func appendDataTimerSelectorHelper(timer: NSTimer){
        var type = timer.userInfo as String
        self.appendAppData(type, showLoadingScreen: false, shouldScrollToMessage: true)
    }
    
    /**
    Function for deleting the timer when not needed anymore
    
    :param: timer The timer to be deleted
    */
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
        label.isAccessibilityElement = false
        
        (view as UIImageView!).image = self.pictures[index]
        return view
    }
    
    
    /**
    Function for checking if the item should be appended when the index is on that item
    */
    func carouselCheckForAppendingItems(){
        
        // If the number is lower then two there will no appending in the carousel, but items will be decremented for array
        if(self.carousel.numberOfItems >= 2){
            
            if (self.carousel.currentItemIndex == self.messagesCount-1){
                if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                    self.appendAppData("1", showLoadingScreen: true, shouldScrollToMessage: false)
                }
            }
            else if (self.carousel.currentItemIndex == self.messagesCount + self.clubNewsCount + self.newsCount-1) {
                if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                    self.appendAppData("2", showLoadingScreen: true, shouldScrollToMessage: false)
                }
            }
            else if(self.carousel.currentItemIndex == self.messagesCount + self.clubNewsCount-1){
                self.appendAppData("3", showLoadingScreen: true, shouldScrollToMessage: false)
            }
        }
    }
    
    /**
    Function for checking if the index has been changed. This will be called every time the Carousel will go to the next item
    */
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
            self.carouselSpeechHelper.carouselSpeechItem(self.carousel.currentItemIndex)
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
    
    /**
    Function for setting up the images the first time the Carousel loads
    :param: index The index from the item to be loaded
    */
    func setImages(index: Int){
        
        switch(self.items[index].getType()){
        case "1":
            pictures.append(UIImage(named:"message.jpg"))
            
            // Check if the user has a profile picture
            if(self.items[index].getFromUserProfilePictureURL() != ""){
                self.setupProfilePicture(index, urlString: self.items[index].getFromUserProfilePictureURL())
            }
            
        case "2":
            pictures.append(UIImage(named:"news.jpg"))
            
        case "3":
            pictures.append(UIImage(named:"corp.jpg"))
        default:
            pictures.append(UIImage(named:"emptyField.jpg"))
            
        }
        
    }
    
    
    /**
    Function for setting up the new profile picture onto the item
    
    :param: index The index to setup the profile picture from
    :param: urlString The URL where the picture is located
    */
    func setupProfilePicture(index: Int, urlString: String){
        var newUrlString = "http://" + self.backEndServerAddress + ":8080/VisioWebApp/profile/image?fileNameKey=" + urlString
        var imgURL: NSURL = NSURL(string: newUrlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
        // Make request to get new data (picture)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                
                if error == nil {
                    self.removeImage(index) // Remove the picture that already has been loaded
                    self.pictures.insert(UIImage(data: data), atIndex: index) // Insert the new one in his place
                    self.carousel.reloadItemAtIndex(index, animated: false) // Reload the index Item for showing new picture
                }
        })
        
    }
    
    /**
    Function for appending a new image to the Carousel
    :param: index The index from which item it has to be loaded in
    */
    func appendImage(index: Int){
        
        switch(self.items[index].getType()){
        case "1":
            pictures.insert(UIImage(named:"message.jpg"), atIndex: index)
            
            // Check if the user has a profile picture or not
            if(self.items[index].getFromUserProfilePictureURL() != ""){
                self.setupProfilePicture(index, urlString: self.items[index].getFromUserProfilePictureURL())
            }
            
        case "2":
            pictures.insert(UIImage(named:"news.jpg"), atIndex: index)
        case "3":
            pictures.insert(UIImage(named:"corp.jpg"), atIndex: index)
        default:
            pictures.insert(UIImage(named:"emptyField.jpg"), atIndex: index)
            
        }
        
    }
    
    /**
    Function for removing the image when item is deleted
    :param: index The index from which the item has been deleted
    */
    func removeImage(index:Int ){
        self.pictures.removeAtIndex(index)
    }
    
    /**
    Function for setting the categoryTypeView (underneath the Carousel)
    
    :param: index For checking which item it has to check it's type on
    :param: isEmpty For checking if the Carousel is empty and should behave differently
    */
    func setCategoryType(index: Int, isEmpty: Bool){
        if(!isEmpty){
            switch(self.items[index].getType()){
            case "1":
                println(self.items[index].getFromUser())
                self.categoryView.setCategoryTypeLabel("Persoonlijk bericht")
                if(self.items[index].getFromUser() != " " || self.items[index].getFromUser().isEmpty){
                    self.categoryView.setCategoryTypeCategoryViewLabel("Van: " + self.items[index].getFromUser())
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
                self.categoryView.setCategoryTypeLabel(self.items[index].getClubType() + "-bericht")
                if(self.items[index].getClubName() != ""){
                    self.categoryView.setCategoryTypeCategoryViewLabel(self.items[index].getClubName())
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
    /**
    Function for making the gesture for the logout button
    */
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
    
    /**
    Function for going to the loginpage when credentials are incorrect. Will also remove all instances inside this viewController
    */
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
    
    /**
    Function for setting the loading bar
    
    :param: title The title to be shown inside the loadingView
    */
    func setLoadingView(title: String){
        // Notification for getting items
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.isAccessibilityElement = true
        loadingNotification.accessibilityLabel = ""
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = title
    }
    
    
    /**
    Function for setting the alertView (yes and no selection) with user interaction
    
    :param: title The title to be shown inside the alertView
    :param: message The message to be shown inside the alertView
    :returns: SIAlertView The alertView so button actions can be added
    */
    func setAlertView(title: String, message: String) -> SIAlertView{
        var alert:SIAlertView  = SIAlertView(title: title, andMessage: message)
        alert.isAccessibilityElement = false
        alert.titleFont = UIFont(name: "Verdana", size: 30)
        alert.messageFont = UIFont(name: "Verdana", size: 26)
        alert.buttonFont = UIFont(name: "Verdana", size: 30)
        alert.transitionStyle = SIAlertViewTransitionStyle.Bounce
        
        return alert
    }
    
    //# MARK: - UIBackground / Foreground methods
    //=================================================================================================
    /**
    Function for delete the old items inside the Carousel and speeching the total items inside the Carousel at the moment of returning into the foreground of the application
    */
    func deleteAndSpeechItemsToForeground(){
        if(self.carousel.numberOfItems != 0){
            if(!self.messageIsOpenend){
                var itemsIndexArray = [Int]()
                
                // Getting the date
                var dateFormatter = NSDateFormatter()
                var date = NSDate()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                // Make new date
                var currentdateString = dateFormatter.stringFromDate(date)
                currentdateString.substringToIndex(advance(currentdateString.startIndex, 10)) // Getting only the year, month day
                
                if(!self.items.isEmpty){
                    
                    // Looping through all the dates of the corresponding items
                    for i in 0...self.items.count-1{
                        if(self.items[i].getType() == "2" || self.items[i].getType() == "3"){
                            var publishedDateString = self.items[i].getPublishDate()
                            
                            // If the current date is not the same as the published date, remove from carousel and append the index to a new array
                            if(currentdateString != publishedDateString){
                                for o in 0...self.items.count-1{
                                    if(self.items[i].getID() == self.items[o].getID()){
                                        self.carousel.removeItemAtIndex(i, animated: false) // Remove from carousel
                                        
                                        // Decrement when removed
                                        if(self.items[i].getType() == "2"){
                                            self.newsCount--
                                        }
                                        else if(self.items[i].getType() == "3"){
                                            self.clubNewsCount--
                                        }
                                        itemsIndexArray.append(i) // Append the index
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                
                // Loop through the index in reverse and delete the item and image
                if(!itemsIndexArray.isEmpty){
                    for j in reverse(0...itemsIndexArray.count-1){
                        self.items.removeAtIndex(itemsIndexArray[j])
                        self.removeImage(itemsIndexArray[j])
                    }
                }
                
                // When there are no more items inside the carousel, the Carousel should behave differently
                if(self.items.isEmpty){
                    self.firstItem = true
                }
                
                self.carousel.reloadData() // Reload the carousel
                
                // Speech the new items and make it accessible
                if(self.userSettings.isTotalNewMessageSoundEnabled()){
                    self.carouselSpeechHelper.speechTotalItemsAvailable(self.messagesCount, clubNewsCount: self.clubNewsCount, newsCount: self.newsCount) // Speech total of items
                }
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                    self.categoryView); // Set the accessibillity view back to the categoryview so user can interact with carousel
                
                // Reload the carousel item to speech it again
                self.carouselCurrentItemIndexDidChange(self.carousel)
                
            }
        }
    }
    
    /**
    Function for stopping the speech when going to the background
    
    :param: notification The notification to be received by the selector
    */
    func stopSpeechItemsToBackground(notification : NSNotification) {
        
        // Stop the current speech
        if(self.userSettings.isSpeechEnabled()){
            self.carouselSpeechHelper.getSpeech().stopSpeech() // Stop speech
        }
    }
    
    // //# MARK: - Seque methods
    //=================================================================================================
    
    /**
    Function for going to another controller. This is when the user tapped on a new item
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showMessageContent"{
            let vc = segue.destinationViewController as MessageContentViewController
            vc.deletingMessage = self
            vc.openendMessage = self
            vc.userDelegate = self
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
            vc.userDelegate = self
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
            vc.userDelegate = self
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
    
    /**
    Function for getting the user settings and store them inside the viewController for proper settings, from the back-end
    
    :param: tokenKey The token from which the access to the back-end is gained
    :param: updateSettings Indicator if the userSettings are being updated. If so, the getAppData should not be executed as other executions within this method
    */
    func getUserSettings(tokenKey: String, updateSettings: Bool){
        var url = "http://" + self.backEndServerAddress + ":8080/VisioWebApp/API/clientSettings?tokenKey=" + tokenKey
        
        if(!updateSettings){
            self.setLoadingView("Gebruikers-instellingen laden...")
        }
        
        UserManager.getUserSettings(url){(settings) in
            
            // If the setting has a return code of 200, all went OK
            if(settings.getReturnCode() == "200"){
                
                // Transfering array to global array
                self.userSettings = settings
                
                // Setting the carouselSpeechHelper with settings for speeching
                self.carouselSpeechHelper = CarouselSpeechHelper(userSettings: self.userSettings) // Singleton carouselSpeechHelper
                self.carouselSpeechHelper.delegate = self // Setting delegate so it can communicate with the Carousel
                
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
                    self.setupBackgroundForegroundInit() // Setting the background foreground methods
                    self.setupAppendingTimer() // Timer for checking new items may execute
                    self.token.hasRefreshToken(true) // For getting the messages
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                    
                    // Getting the app data and fill it in the global array
                    self.getAppData(self.token.getToken())
                }
            }
            else if(settings.getReturnCode() == "400"){
                if(!updateSettings){
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                }
                if(self.token.isRefreshToken()){
                    self.token.hasRefreshToken(false)
                    self.getUserSettings("http://" + self.backEndServerAddress + ":8080/VisioWebApp/API/clientSettings?tokenKey=" + self.token.getRefreshToken(), updateSettings: false)
                }
                else{
                    // Send user back to login phase
                    self.goToLogin()
                }
            }
            else{
                if(!updateSettings){
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                }
                
                // Make alert with buttons and show it to the user
                var alert = self.setAlertView("Probleem", message: "Kon instellingen niet ophalen. Wil je het opnieuw proberen?")
                alert.addButtonWithTitle("Ja", type: SIAlertViewButtonType.Default, handler:{ (ACTION :SIAlertView!)in
                    
                    // Try it again
                    self.getUserSettings(self.token.getToken(), updateSettings: false)
                })
                alert.addButtonWithTitle("Nee", type: SIAlertViewButtonType.Cancel, handler:{ (ACTION :SIAlertView!)in
                    
                    // Send user back to login phase
                    self.goToLogin()
                })
                alert.show()
            }
        }
    }
    
    //# MARK: - items and news data methods
    //=================================================================================================
    
    /**
    Function for getting all the data for the first time, from the back-end
    :param: tokenKey The token from which the access to the back-end is gained
    */
    func getAppData(tokenKey: String){
        var url = "http://" + self.backEndServerAddress + ":8080/VisioWebApp/API/chat/allMessages?tokenKey=" + tokenKey
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
                            
                            // If the limit has been reached, break the loop
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
                            
                            // If the limit has been reached, break the loop
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
                            
                            // If the limit has been reached, break the loop
                            if(self.clubNewsCount == self.userSettings.getClubNewsMessageLimit()){
                                break
                            }
                        }
                    }
                    
                    if(self.userSettings.isTotalNewMessageSoundEnabled()){
                        
                        // Seepching total of items
                        self.carouselSpeechHelper.speechTotalItemsAvailable(self.messagesCount, clubNewsCount: self.clubNewsCount, newsCount: self.newsCount)
                    }
                    
                    // Check if carousel has items, if not, there is no first item and method should not be executed
                    if(!self.items.isEmpty){
                        if(self.firstItem){
                            self.carouselSpeechHelper.carouselSpeechItem(self.carousel.currentItemIndex) // Speeching the first item inside the carousel
                        }
                    }
                    
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                    
                    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification,
                        self.categoryView); // Set the accessibillity view back to the categoryview so user can interact with carousel
                }
                    
                    // If the code is something else, the token is incorrect. Login again
                else{
                    if(items[0].getReturnCode() == "400"){
                        if(self.token.isRefreshToken()){
                            
                            // Set the refreshToken to false and insert the refreshToken
                            self.token.hasRefreshToken(false)
                            self.getAppData("http://" + self.backEndServerAddress + ":8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token.getRefreshToken())
                        }
                            
                            // Close the view and go to login
                        else{
                            println("NOT correct")
                            
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
                            
                            // Send user back to login phase
                            self.goToLogin()
                        }
                        
                    }
                        
                        // Else, something went wrong and the user will be prompted to try again
                    else{
                        
                        // Make new alertView for user to interact with
                        var alert = self.setAlertView("Probleem", message: "Kon berichten niet ophalen. Wil je het nog een keer proberen?")
                        alert.addButtonWithTitle("Ja", type: SIAlertViewButtonType.Default, handler:{ (ACTION :SIAlertView!)in
                            
                            // Try again
                            self.getAppData(self.token.getToken())
                        })
                        alert.addButtonWithTitle("Nee", type: SIAlertViewButtonType.Cancel, handler:{ (ACTION :SIAlertView!)in
                            
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
                    self.carouselSpeechHelper.speechNoItemsAvailable()
                }
                
                // If there are less then 2 items available, the categoryTypeView should state the Carousel is empty
                if(self.carousel.numberOfItems < 2){
                    
                    self.categoryView.hidden = false // Unhide view
                    self.setCategoryType(0, isEmpty: true) // 0 is when Carousel is empty
                }
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true) // Close notification
            }
        }
    }
    
    
    
    /**
    Function for appending new items into the existing Carousel. A part of the function is inside the datahelper because of the reusability of that code
    
    :param: type The type of message the Carousel should append.
    0 = all items
    1 = messages
    2 = news items
    3 = clubNews items
    
    :param: showLoadingScreen Indicator for showing the loading screen or do a silent appending (timers)
    :param: shouldScrollToMessage Indicator for skipping scrolling to the last item known, but going to the item to be scrolled to
    */
    func appendAppData(type: String, showLoadingScreen: Bool, shouldScrollToMessage: Bool){
        
        // Execute only when no item is opened
        if(!self.messageIsOpenend){
            var oldID = "0" // When there are no items in carousel, there is no old ID
            if(!self.firstItem){
                oldID = self.items[self.carousel.currentItemIndex].getID()
            }
            var carouselDataHelper = CarouselDataHelper() // Make the datahelper
            var url = "http://" + self.backEndServerAddress + ":8080/VisioWebApp/API/chat/allMessages?tokenKey=" + self.token.getToken() // URL for JSON
            
            // Show loading screen if set to true
            if(showLoadingScreen){
                self.setLoadingView("Nieuwe berichten laden")
            }
            
            // Get the data
            DataManager.getItems(url){(items) in
                
                // Processing the data
                if(!items.isEmpty && items[0].getReturnCode() == "200"){
                    
                    var newIDArray:[Int] = carouselDataHelper.getAllItemIDs(self.items, newItems: items, type: type) // Getting all the ID's from old and new arrays
                    
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
                                        
                                        // May only append if the limit has not been reached
                                        if(self.messagesCount < self.userSettings.getPrivateMessageLimit()){
                                            indexHasChanged = true // New items may be speeched
                                            
                                            self.items.insert(items[l], atIndex: self.messagesCount)
                                            
                                            // Append the image and insert the item
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
                                        
                                        // May only append if the limit has not been reached
                                        if(self.newsCount < self.userSettings.getNewsMessageLimit()){
                                            
                                            indexHasChanged = true // New items may be speeched
                                            
                                            var indexNewsCount = self.messagesCount + self.clubNewsCount + self.newsCount // The last item that was inserted
                                            
                                            // Append the image and insert the item
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
                                        
                                        // May only append if the limit has not been reached
                                        if(self.clubNewsCount < self.userSettings.getClubNewsMessageLimit()){
                                            
                                            indexHasChanged = true // New items may be speeched
                                            
                                            var indexClubNewsCount = self.messagesCount + self.clubNewsCount // The last item that was inserted
                                            
                                            // Append the image and insert the item
                                            self.items.insert(items[l], atIndex: indexClubNewsCount)
                                            self.appendImage(indexClubNewsCount)
                                            self.carousel.insertItemAtIndex(indexClubNewsCount, animated: true)
                                            
                                            //Add the amount of messages or news
                                            newClubNews++
                                            self.clubNewsCount++
                                        }
                                        else{
                                            break
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        if(newMessages != 0){
                            // Show notification if loading screen is set to true
                            if(showLoadingScreen){
                                self.showNotificationNewItems(newMessages)
                            }
                        }
                        else if(newClubNews != 0){
                            // Show notification if loading screen is set to true
                            if(showLoadingScreen){
                                self.showNotificationNewItems(newClubNews)
                            }
                        }
                        else if(newNews != 0){
                            // Show notification if loading screen is set to true
                            if(showLoadingScreen){
                                self.showNotificationNewItems(newNews)
                            }
                        }
                        
                        // If the index has changed (appended item), speech the total of new items
                        if(indexHasChanged){
                            var scrollToMessage = false
                            
                            // Speech the total of new items
                            if(self.userSettings.isNotificationSoundEnabled()){
                                if(newMessages > 0){
                                    self.carouselSpeechHelper.newItemsToSpeech(newMessages, type: "1")
                                    if(shouldScrollToMessage){
                                        if(self.carousel.numberOfItems > 2){
                                            scrollToMessage = true // Already scrolling, so set to false
                                            self.isAppending = false // Set it to false for speeching
                                            self.carousel.scrollToItemAtIndex(self.messagesCount-1, animated: true) // Scroll to the item
                                        }
                                    }
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
                                if(shouldScrollToMessage && indexHasChanged){
                                     if(self.carousel.numberOfItems > 2){
                                        self.carouselSpeechHelper.speechCarouselScrollItem(self.messagesCount-1)
                                    }
                                }
                                self.isAppending = true // Set it to true again
                            }
                            
                            // If there was no scroll, it should scroll to the last known item
                            if(!scrollToMessage){
                                
                                //Get back to the item carousel where the user was focussed on
                                for p in 0...self.items.count-1{
                                    
                                    // Old ID found, get back to it
                                    if(oldID == self.items[p].getID()){
                                        self.carousel.scrollToItemAtIndex(p, animated: false)
                                        self.carouselCurrentItemIndexDidChange(self.carousel) // Reload the view
                                        break
                                    }
                                    else{
                                        // Not found, at the ending change the index and set appending to false for speech
                                        if(p == self.items.count-1){
                                            println("NOT FOUND")
                                            self.isAppending = false
                                            if(!self.firstItem){
                                                self.carouselCurrentItemIndexDidChange(self.carousel) // Reload the view
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            
                            // Check if carousel has items
                            if(!self.items.isEmpty){
                                if(self.firstItem){
                                    self.carouselSpeechHelper.carouselSpeechItem(self.carousel.currentItemIndex) // Speeching the first item inside the carousel
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
        }
        
    }
    
    /**
    Function for showing the notificationDot when there are new items
    :param: totalNewItems The total of new items that should be inside the dot
    */
    func showNotificationNewItems(totalNewItems: Int){
        // If the animation is not already active, start it
        if(!self.notificationDot.getDotView().isAnimating()){
            self.notificationDot.getDotView().startAnimating()
            self.notificationDot.getDotView().addSubview(self.notificationText.getNotificationTextView())
        }
        
        self.notificationText.setNotificationTextView(String(totalNewItems)) // Update the text
        self.notificationText.showNotificationTextView()
        self.notificationDot.showDotView() // Show dot
    }
    
    //# MARK: - Data deletion methods
    //=================================================================================================
    
    /**
    Function for deleting the message when closing the item inside another controller
    
    :param: carouselMessageNumber The ID from the item, from within the Carousel, to be deleted
    :param: type The type of item to be deleted, as in the AppendData method
    */
    func deleteMessage(carouselMessageNumber: String, _ type: String){
        var timerManager = TimerManager() // Manager for keeping the time
        
        // Look for ID
        for i in 0...self.items.count-1{
            
            // If the ID is the same as the carouselMessageNumber, it should append to the array for futher deletion
            if(self.items[i].getID() == carouselMessageNumber){
                deleteditemIndexes.append(String(i)) // Appending the carouselMessageNumber to the deleteditemIndex
                break
            }
        }
        
        var carouselItemIndex = self.deleteditemIndexes.first?.toInt() // Getting first item from the array
        self.deleteditemIndexes.removeAtIndex(0) // Delete it from the array because we have copied it
        
        var messageID = self.items[carouselItemIndex!].getID() // Get the message ID for putting into the URL for deleting it within the back-end
        
        var url = "http://" + self.backEndServerAddress + ":8080/VisioWebApp/API/chat/confirm?messageId=" + String(messageID) + "&type=" + type
        
        // Delete it from the back-end
        DataManager.checkMessageRead(url){(codeFromJSON) in
            
            if(codeFromJSON == "200"){
                println("Deleted item")
            }
        }
        
        // Getting the max seconds upon checking the type and execute the timer
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
        
        var newTimer = timerManager.startTimer(self, selector: Selector("deleteMessageInsideCarousel:"), userInfo: carouselItemIndex!, interval: interval) // Start timer
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
            self.categoryView); // Make the categoryTypeView the new element to focus on when having voice over on, so user can scroll with three fingers again
        
    }
    
    /**
    Selector for making message read and deleting it from carousel
    
    :param: timer The timer from which the data came
    */
    func deleteMessageInsideCarousel(timer: NSTimer){
        self.isAppending = true // Speech may not execute
        let carouselItemIndex = timer.userInfo as Int // Convert timer info to String
        var oldID =  self.items[self.carousel.currentItemIndex].getID() // Old ID whe deletion executed
        
        // Checking what kind of message was deleted
        if(self.items[carouselItemIndex].getType() == "1"){
            self.messagesCount--
        }
        else if(self.items[carouselItemIndex].getType() == "2"){
            self.newsCount--
        }
        else if(self.items[carouselItemIndex].getType() == "3"){
            self.clubNewsCount--
        }
        
        println("Deleting..." + String(carouselItemIndex))
        self.items.removeAtIndex(carouselItemIndex) // Remove it from the items array
        self.carousel.removeItemAtIndex(carouselItemIndex, animated: true) // Remove it from Carousel
        self.removeImage(carouselItemIndex) // Lastely, remove the image
        
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
