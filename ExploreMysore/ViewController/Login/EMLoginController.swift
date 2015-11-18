//
//  EMLoginController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 05/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse
class EMLoginController: UIViewController,KASlideShowDelegate,UITextFieldDelegate
{
    @IBOutlet var slideShow: KASlideShow!
    @IBOutlet var appName: UILabel!
    @IBOutlet var emailImage: UIImageView!
    @IBOutlet var passwordImage: UIImageView!
    @IBOutlet var loginbtn: UIButton!
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var keyIcon: UIImageView!
    @IBOutlet var userBar: UIView!
    @IBOutlet var keyBar: UIView!
    @IBOutlet var startExpo: UILabel!
    @IBOutlet var accountLabel: UILabel!
    @IBOutlet var forgot: UIButton!
    @IBOutlet var signupBtn: UIButton!
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    var SuccessLogin = Bool()
    var CustomAlert =  SCLAlertView()


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SuccessLogin =  false
        setUpInitialUIFromView()
        let move:Bool = NSUserDefaults.standardUserDefaults().boolForKey("loggedIn") as Bool
        if move
        {
            moveToHome()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        userNameTextField.text = ""
        passwordTextField.text = ""
        
        if EMHelper.sharedInstance.isFromForgotPassword
        {
            CustomAlert.showSuccess(self, title:"Success", subTitle:"An email containing information on how to reset your password has been sent to your mailId", closeButtonTitle:"OK",duration: 0.0)
        }
        else if EMHelper.sharedInstance.isFromSignUp
        {
           CustomAlert.showSuccess(self, title:"Success", subTitle:"Signed Up Successfully!", closeButtonTitle:"OK",duration: 0.0)
        }
        else if EMHelper.sharedInstance.isFromAccount
        {
           CustomAlert.showWarning(self, title:"Security Reason!", subTitle:"Login With Your New Password", closeButtonTitle:"Ok", duration: 0.0)
        }
    }
    
    //MARK:-Login Action
    @IBAction func loginBtnTapped(sender: AnyObject)
    {
        ActivityIndicator.shared.startAnimating(view)
        passwordTextField .resignFirstResponder()
        if !userNameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty
        {
            // Send a request to login
            NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text, forKey: "userPassword")
            NSUserDefaults.standardUserDefaults().synchronize()
            PFUser.logInWithUsernameInBackground(userNameTextField.text!, password:passwordTextField.text!, block: { (user, error) -> Void in
                // Stop the spinner
                
                if ((user) != nil) {
                    self.SuccessLogin = true
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                       //Need to Home Screen
                        ActivityIndicator.shared.stopAnimating()
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey:"loggedIn")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.moveToHome()
                    })
                }
                else
                {
                    ActivityIndicator.shared.stopAnimating()
                    self.displayAlert("Error!",message:"Something Went Wrong!")
                }
            })
        }
        else
        {
            displayAlert("Warning!",message:"Please fill all fields!")
        }
    }
    
    
    //MARK:-SignupAction
    @IBAction func signupBtnTapped(sender: AnyObject)
    {
        slideShow.stop()
        performSegueWithIdentifier("MovingToSignup", sender: self)
    }
    
    //MARK:-Forgot Action
    @IBAction func forgotBtnTapped(sender: AnyObject)
    {
        slideShow.stop()
        performSegueWithIdentifier("MovingToForgot", sender: self)
    }
    
    //MARK:-UITextField Delegate Method
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == userNameTextField
        {
            passwordTextField .becomeFirstResponder()
        }
        return true
    }
    
    //MARK:- Single method to display alert
    func displayAlert(title:String,message:String)
    {
        if SuccessLogin != false
        {
            SuccessLogin = false
            CustomAlert.showSuccess(self, title:title, subTitle:message, closeButtonTitle:"OK",duration: 0.0)
        }
        else
        {
            CustomAlert.showError(self, title:title, subTitle: message, closeButtonTitle:"OK", duration:0.0)
        }
    }

    //Pushing to Home viewcontroller
    func moveToHome()
    {
        self.performSegueWithIdentifier("MovingToHome", sender: self)
    }
    
    
    //MARK:- Creating UI for view
    func setUpInitialUIFromView()
    {
        slideShow.delegate = self
        slideShow.addImagesFromResources(["toppalace.jpg"])
        slideShow.imagesContentMode = UIViewContentMode.ScaleToFill
        
        userNameTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()

        //Display other
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(),
        {
                NSThread.detachNewThreadSelector(Selector("slideViewOfImage"), toTarget:self, withObject:nil)
        })
        
        loginbtn.layer.cornerRadius = 4.0;
        signupBtn.layer.cornerRadius = 4.0;
        slideShow .bringSubviewToFront(appName)
        slideShow .bringSubviewToFront(emailImage)
        slideShow .bringSubviewToFront(passwordImage)
        slideShow .bringSubviewToFront(loginbtn)
        slideShow .bringSubviewToFront(userIcon)
        slideShow .bringSubviewToFront(keyIcon)
        slideShow .bringSubviewToFront(userBar)
        slideShow .bringSubviewToFront(keyBar)
        slideShow .bringSubviewToFront(userNameTextField)
        slideShow .bringSubviewToFront(passwordTextField)
        slideShow .bringSubviewToFront(startExpo)
        slideShow .bringSubviewToFront(accountLabel)
        slideShow .bringSubviewToFront(signupBtn)
        slideShow .bringSubviewToFront(forgot)

        
        let placeHolderColor = UIColor.whiteColor()
        userNameTextField.attributedPlaceholder  = NSAttributedString(string:"UserName", attributes:[NSForegroundColorAttributeName:placeHolderColor])
        passwordTextField.attributedPlaceholder  = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName:placeHolderColor])
    }
    
    //MARK:- Functionality for creating Fade Animations
    func slideViewOfImage()
    {
        // KASlideshow
        slideShow.delay = 2.0
        slideShow.transitionDuration = 4.0
        slideShow.transitionType = KASlideShowTransitionType.Fade
        slideShow.imagesContentMode = UIViewContentMode.ScaleToFill
        slideShow.addImagesFromResources(["lalita mahal.jpg","gopuram.jpg","Nandi.jpg","chruch.jpg","golden-budda.jpg","mysore dosa.jpg","mysoresilk.jpg","yogam.jpg","somanathpura.jpg"])
        slideShow.start()
    }
}
