
//
//  ViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, iCarouselDataSource, iCarouselDelegate
{
    // Array for all the items to be loaded inside the carousel
    var items: [Message] = []
    var pictures: [UIImage!] = []
    
    // For passing on to the other ViewControllers
    var currentIndex: Int = 0
    @IBOutlet var carousel : iCarousel!
    @IBOutlet weak var categoryMessage: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // URL for the JSON
        var url = "https://itunes.apple.com/us/rss/topgrossingipadapplications/limit=2/json"
        
        // Getting the app data and fill it in the global array
        getAppData(url)
        
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
        var imageViewObject :UIImageView! = nil
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            view = UIImageView(frame:CGRectMake(0, 0, 200, 200))
            view.contentMode = .Center
            
            
            
            label = UILabel(frame:view.bounds)
            label.frame = CGRectMake(-140, -150, 500, 100);
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(50)
            label.tag = 1
            
            
            // view.addSubview(imageViewObject)
            view.addSubview(label)
        }
        else
        {
            //get a reference to the label in the recycled view
            label = view.viewWithTag(1) as UILabel!
        }
        
        // If the index is the same as the carousel, it will check in what kind of category the message/news is
        if (index == self.carousel.currentItemIndex) {
            setCategories(index)
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
    
    // Function for getting the app data and filling it into the array
    func getAppData(url: String){
        DataManager.getMainData(url){(messages) in
            
            // Transfering array to global array
            self.items = messages
            
            // Iterate through all possible values
            for r in 0...self.items.count-1{
                self.carousel.insertItemAtIndex(r, animated: true)
                println(self.items[r].getName())
            }
        }
        
    }
    
    // Function for setting the images per category
    func setImages(index: Int){
        
        switch(items[index].getName()){
            case "Clash of Clans":
            pictures.append(UIImage(named:"page.png"))
            
            case "Game of War - Fire Age":
             pictures.append(UIImage(named:"naamloos.png"))
            
        default:
             pictures.append(UIImage(named:"naamloos.png"))
            
        }
        
    }
    
    // Setting the categorie names above the carousel
    func setCategories(index: Int){
        switch(items[index].getName()){
            case "Game of War - Fire Age":
            categoryMessage.text = "Categorie: Berichten"
            
            case "Clash of Clans":
            categoryMessage.text = "Categorie: Mededelingen"
            
        default:
            categoryMessage.text = "Geen categorie"

            break
            
        }
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!){
        self.carousel.reloadData()
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


