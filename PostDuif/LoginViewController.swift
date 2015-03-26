//
//  LoginViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 23-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var loginEmail: UITextField!
    
    @IBOutlet weak var loginPincode1: UITextField!
    @IBOutlet weak var loginPincode2: UITextField!
    @IBOutlet weak var loginPincode3: UITextField!
    var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rightSwiped(){
        
        var pincode = self.loginPincode1.text + "-" + self.loginPincode2.text + "-" + self.loginPincode3.text
        
        var url = "http://84.107.107.169:8080/VisioWebApp/API/authentication?email=" + self.loginEmail.text + "&pincode=" + pincode

        println(pincode)
        
        UserManager.loginUser(url){(code) in
            
            // Transfering array to global array
            self.code = code
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
