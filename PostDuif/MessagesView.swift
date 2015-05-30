//
//  MessageView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for all the content inside the messagesContentViewController

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
    
    
    /**
    Function for setting the title inside the message
    
    :param: text The text to be inserting inside the message
    */
    func setTitleText(text: String){
        self.messageTitle.text = text
    }
    
    /**
    Function for setting the background inside the whole view
    
    :param: color The color to be inserted inside the whole view
    */
    func setViewBackground(color: String){
        self.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting the background for the title
    
    :param: color The backgroundcolor to be inserted into the message title
    */
    func setTitleBackground(color: String){
        self.messageTitle.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting up the title itself, with borders and colors
    */
    func setupTitle(){
        var borderColor : UIColor = UIColor.grayColor()
        self.messageTitle.layer.borderWidth = 1
        self.messageTitle.layer.borderColor = borderColor.CGColor
        self.messageTitle.layer.cornerRadius = 0
    }
    
    /**
    Function for setting the background for the content inside the message
    
    :param: color The backgroundcolor to be inserted into the message content
    */
    func setContentBackground(color: String){
        self.messageContent.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.contentView.backgroundColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
    }
    
    /**
    Function for setting the font color inside the title and content
    
    :param: color The color for the fonts
    */
    func setFontColor(color: String){
        self.messageTitle.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.messageContent.textColor = ColorHelper.UIColorFromRGB(color, alpha: 1)
        self.attachmentDescriptionColor = color
    }
    
    /**
    Function for setting the text for the message to be inserted
    
    :param: text The text to be inserted inside the content
    */
    func setMessageText(text: String){
        self.messageContent.text = text
        self.messageContent.sizeToFit() // Making the content size for fitting
        
        // If the content size is smaller then the minimal, resize to the minimal height
        if(messageContent.frame.size.height < self.minimalHeight){
            self.messageContent.frame.size.height = self.minimalHeight
        }
    }
    
    /**
    Function for setting the size of the font
    
    :param: size The size of the font text
    */
    func setFontSize(size: CGFloat){
        self.messageContent.font = UIFont(name: "Verdana", size: size)
        self.attachmentDescriptionFontSize = size
    }
    
    /**
    Function for setting up the content itself (messageContent)
    */
    func setupContent(){
        var borderColor : UIColor = UIColor.grayColor()
        self.scroller.layer.borderWidth = 1
        self.scroller.layer.borderColor = borderColor.CGColor
        self.scroller.layer.cornerRadius = 0
        self.personalPicture.hidden = true
    }
    
    /**
    Function for setting up the picture (if present) inside the messageContent
    
    :param: urlString The URL of the picture that should be inside the message
    :param: attachmentDescription The description that should be underneath the picture
    */
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
                        var centerWidth = self.messageContent.center.y - self.messageContent.center.y/2
                        
                        self.personalPicture.frame = CGRectMake(centerWidth, self.messageContent.frame.size.height + 60, self.personalPicture.frame.size.width, self.personalPicture.frame.size.height) // Making the new size of the picture frame
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
    
    /**
    Function for setting up the contentView. This view should be responsible for containing all the elements visible to the user
    
    :param: pictureLoaded Giving if picture is loaded or not, if the contentView should stretch or not
    */
    private func setupContentView(pictureLoaded: Bool){
        if(pictureLoaded){
            self.contentView.sizeToFit() // Fit the size again (is changed because of picture and description)
            
            // Make the new frame height
            self.contentView.frame.size.height = self.messageContent.frame.size.height + self.personalPicture.frame.size.height + self.attachmentDescription.frame.size.height + 80
        }
        else{
            // No picture is loaded, only text present
            self.contentView.frame.size.height = self.messageContent.frame.size.height
        }
        
        self.setupScrollView() // Add the ScrollView for scrolling
        
    }
    
    /**
    Function setting, and adding the attachment description
    
    :param: attachmentDescription The description that needs to be present underneath the picture
    */
    private func setAttachmentDescription(attachmentDescription: String){
        var centerWidth = self.messageContent.center.y - self.messageContent.center.y/2
        self.attachmentDescription = UILabel(frame: CGRectMake(centerWidth, self.messageContent.frame.size.height + 60 + self.personalPicture.frame.height, self.personalPicture.frame.size.width, 50)) // Making the frame
        
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
    
    /**
    Function setting up the swiping inside the view
    */
    private func setupSwipingScroller(){
        self.setupSwiping()
    }
    
    /**
    Function for setting up the scrollView
    */
    private func setupScrollView(){
        scroller.showsHorizontalScrollIndicator = true
        scroller.scrollEnabled = true
        scroller.contentSize.height = self.contentView.frame.height // Getting the content height for scrolling correctly
    }
    
    /**
    Function for setting up the swiping for closing message
    */
    func setupSwiping(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
    }
    
    /**
    Function for selector, swiping to the left to close message
    */
    func leftSwiped(){
        self.delegate.speech.stopSpeech() //Stop speech
        self.delegate.dismissController() // Dismiss the controller
    }
    
    /**
    Function when accessibility has been activated. It will check if three fingers will go to the direction
    */
    override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
        if (direction == UIAccessibilityScrollDirection.Left) {
            self.leftSwiped()
        }
        UIAccessibilityPostNotification(UIAccessibilityPageScrolledNotification, nil)
        return true
    }
    
    
}

