//
//  MessageView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation
import AVFoundation

class MessagesView: UIView, messagesContentTextViewDelegate{
    private let minimalHeight: CGFloat = 580
    private var attachmentDescription: UILabel!
    private var attachmentDescriptionColor: String!
    private var attachmentDescriptionFontSize: CGFloat!
    
    var delegate: messagesDelegate!
    
    @IBOutlet weak private var messageTitle: UITextView!
    @IBOutlet weak var messageContent: UITextView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var personalPicture: UIImageView!


    func setTitleText(text: String){
        self.messageTitle.text = text
    }
    
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setTitleBackground(color: String){
        self.messageTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.messageTitle.layer.borderWidth = 1
        self.messageTitle.layer.borderColor = borderColor.CGColor
        self.messageTitle.layer.cornerRadius = 0
    }

    func setContentBackground(color: String){
        self.messageContent.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    func setFontColor(color: String){
        self.messageTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.messageContent.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.attachmentDescriptionColor = color
    }
    
    func setMessageText(text: String){
        self.messageContent.text = text
        self.messageContent.sizeToFit()
        if(messageContent.frame.size.height < self.minimalHeight){
            self.messageContent.frame.size.height = self.minimalHeight
        }
    }
    
    func setFontSize(size: CGFloat){
        self.messageContent.font = UIFont(name: "Verdana", size: size)
        self.attachmentDescriptionFontSize = size
    }
    
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.scroller.layer.borderWidth = 1
        self.scroller.layer.borderColor = borderColor.CGColor
        self.scroller.layer.cornerRadius = 0
        self.personalPicture.hidden = true
    }
    
    // Setting up new picture and description
    func setupPicture(urlString: String, attachmentDescription: String){
        if(urlString != ""){
            var newUrlString = "http://84.107.107.169:8080/VisioWebApp/file/attachment?fileNameKey=" + urlString
            var imgURL: NSURL = NSURL(string: newUrlString)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            
            // Make request to get new data (picture)
            NSURLConnection.sendAsynchronousRequest(
                request, queue: NSOperationQueue.mainQueue(),
                completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    
                    // Getting the width / height from picture
                    var imageWidth: CGFloat!
                    var imageHeight: CGFloat!
                    if error == nil {
                        self.personalPicture.image = UIImage(data: data) // Getting picture
                        imageWidth = self.personalPicture.image?.size.width
                        imageHeight = self.personalPicture.image?.size.height
                    }
                    if(self.personalPicture != nil){
                        self.messageContent.sizeToFit() // Make the content size fit (is still minimalheight)
                        self.personalPicture.frame = CGRectMake(self.frame.size.width/2/2, self.messageContent.frame.size.height + 60, imageWidth, imageHeight) // Making the new size of the picture frame
                        self.personalPicture.hidden = false // Show the picture
                        
                        self.setAttachmentDescription(attachmentDescription) // Setting the attachmentDescription
                        
                        self.setupContentView(true) // Make new total size and add scrollview
                    }
                    
            })
            self.setupContentView(false) // Make new total size and add scrollview
        }
        else{
            self.setupContentView(false) // Make new total size and add scrollview
        }

    }
    
    // Function for setting up the new contentView
    private func setupContentView(pictureLoaded: Bool){
        if(pictureLoaded){
            self.contentView.sizeToFit() // Fit the size again (is changed because of picture and description)
            
            // Make the new frame height
            self.contentView.frame.size.height = self.messageContent.frame.size.height + self.personalPicture.frame.size.height + self.attachmentDescription.frame.size.height + 80
        }
        else{
            self.contentView.frame.size.height = self.messageContent.frame.size.height + self.personalPicture.frame.size.height
        }
        
        self.setupScrollView() // Add the ScrollView for scrolling
        
    }
    
    // Function for programmatically adding the attachment description
    private func setAttachmentDescription(attachmentDescription: String){
        
        self.attachmentDescription = UILabel(frame: CGRectMake(self.frame.size.width/2/2, self.messageContent.frame.size.height + self.personalPicture.frame.height + 60, self.personalPicture.frame.size.width, 50)) // Making the frame
        
        // Label options
        self.attachmentDescription.textAlignment = NSTextAlignment.Center
        self.attachmentDescription.numberOfLines = 5
        self.attachmentDescription.text = attachmentDescription
        self.attachmentDescription.isAccessibilityElement = true
        self.attachmentDescription.accessibilityHint = "Beschrijving foto: "
        self.attachmentDescription.accessibilityLabel = self.attachmentDescription.text
        self.attachmentDescription.textColor = ColorHelper.UIColorFromRGB(self.attachmentDescriptionColor, alpha: 1)
        self.attachmentDescription.font = UIFont(name: "Verdana", size: self.attachmentDescriptionFontSize)
        self.contentView.addSubview(self.attachmentDescription) // Add it to the subView
        
    }
    
    // Setting up the swipe
    private func setupSwipingScroller(){
        self.setupSwiping()
    }
    
    // Setting up the scrollView
    private func setupScrollView(){
        scroller.showsHorizontalScrollIndicator = true
        scroller.scrollEnabled = true
        scroller.contentSize.height = self.contentView.frame.height // Getting the content height for scrolling correctly
    }
    
    func setupSwiping(){
        
        //------------right  swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    
    //------------Swipe method to the right--------------//
    func leftSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }
    
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        
        return true
    }
    
    
}

