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
    var items: [String] = []
    
    // For passing on to the other ViewControllers
    var currentIndex: Int = 0
    @IBOutlet var carousel : iCarousel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Appending new items (now string, but also could be objects)
        items.append("Bericht 1")
        items.append("Bericht 2")
        items.append("Bericht 3")
        items.append("Bericht 4")
        items.append("Bericht 5")
        items.append("Bericht 6")
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
        
        // For performing the seque inside the storyboard
        performSegueWithIdentifier("showContent", sender: self)
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
            (view as UIImageView!).image = UIImage(named: "page.png")
            view.contentMode = .Center
        
            label = UILabel(frame:view.bounds)
            label.frame.origin.y -= 250.0
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.font = label.font.fontWithSize(50)
            label.tag = 1
            
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
        label.text = "\(items[index])"
        
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
        if segue.identifier == "showContent"{
            let vc = segue.destinationViewController as ContentView
            vc.colorString = String(currentIndex)
        }
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

