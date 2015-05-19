//
//  CategoryView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 19-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for the categoryType, labels and view itself

import Foundation

class CategoryTypeView: UIView{
    @IBOutlet weak private var categoryTypeViewLabel: UILabel!
    @IBOutlet weak private var categoryTypeCategoryViewLabel: UILabel!
    
    
    /**
    Function for setting the categoryLabel
    
    :param: text The text for label
    */
    func setCategoryTypeLabel(text: String){
        self.categoryTypeViewLabel.text = text
    }
    
    
    /**
    Function for setting the categoryTypeLabel (underneath the first label)
    
    :param: text The text to be inserted inside the second label
    */
    func setCategoryTypeCategoryViewLabel(text: String){
        self.categoryTypeCategoryViewLabel.text = text
    }
    
    
    /**
    Function for getting the categoryLabel
    
    :returns: String The first label
    */
    func getCategoryLabel() -> String{
        return self.categoryTypeViewLabel.text!
    }
    
    /**
    Function for getting the categoryTypeLabel
    
    :returns: String The second label
    */
    func getCategoryType() -> String{
        return self.categoryTypeCategoryViewLabel.text!
    }
    
    /**
    Function for making a animation when the context of the item changes
    
    :param: color Is the color to be changed when animating
    */
    func nextItemAnimate(color: UIColor){
        self.backgroundColor = color // Set the new color of view
        
        var views = UIView() // Make new view
        views.frame = CGRect(x: 204, y: 600, width: 613, height: 118) // Set frame
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.TransitionCrossDissolve
        
        UIView.transitionWithView(self, duration: 1.0, options: transitionOptions, animations: {
            
            // remove the front object...
            views.removeFromSuperview()
            
            // ... and add the other object
            self.addSubview(views)
            
            }, completion: { finished in
        })
        
    }
    
}