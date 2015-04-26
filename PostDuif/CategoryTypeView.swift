//
//  CategoryView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 19-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class CategoryTypeView: UIView{
    @IBOutlet weak var categoryTypeViewLabel: UILabel!
     @IBOutlet weak var categoryTypeCategoryViewLabel: UILabel!
    
    // Setting the label inside the view
    func setCategoryTypeLabel(text: String){
        self.categoryTypeViewLabel.text = text
    }
    
    func setCategoryTypeCategoryViewLabel(text: String){
        self.categoryTypeCategoryViewLabel.text = text
    }
    
    // Making animation with transition of type
    func nextItemAnimate(color: UIColor){
        self.backgroundColor = color // Set the new color of view
        
        var views = UIView() // Make new view
        views.frame = CGRect(x: 204, y: 600, width: 613, height: 118) // Set frame
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.TransitionFlipFromRight
        
        UIView.transitionWithView(self, duration: 1.0, options: transitionOptions, animations: {
            
            // remove the front object...
            views.removeFromSuperview()
            
            // ... and add the other object
            self.addSubview(views)
            
            }, completion: { finished in
                // any code entered here will be applied
                // .once the animation has completed
        })

    }

}