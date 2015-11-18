
//
//  EMForgotPasswordController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 09/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse
class EMForgotPasswordController: UIViewController,KASlideShowDelegate,UITextFieldDelegate
{

    @IBOutlet var slideShow: KASlideShow!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var appName: UILabel!
    @IBOutlet var enterEmail: UILabel!
    @IBOutlet var emailIcon: UIImageView!
    @IBOutlet var keyIcon: UIImageView!
    @IBOutlet var keyView: UIView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var restBtn: UIButton!
    var successForgot = Bool()
    var CustomAlert =  SCLAlertView()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        slideShow.delegate = self
        setUpInitialUIFromView()
        
    }

    @IBAction func backBtnTapped(sender: AnyObject)
    {
        slideShow.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    @IBAction func restSetBtnTapped(sender: AnyObject)
    {
        ActivityIndicator.shared.startAnimating(view)
        if !emailTextField.text!.isEmpty
        {
            let emailAddress = emailTextField.text
            PFUser.requestPasswordResetForEmailInBackground(emailAddress!, block: { (success:Bool, error:NSError?) -> Void in
                if (success)
                {
                    self.successForgot = true
                    EMHelper.sharedInstance.isFromForgotPassword = true
                    EMHelper.sharedInstance.isFromAccount = false
                    EMHelper.sharedInstance.isFromSignUp = false
                    ActivityIndicator.shared.stopAnimating()

                    self.slideShow.stop()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else
                {
                    ActivityIndicator.shared.stopAnimating()
                    self.displayAlert("Warning!", message:"Something Went Wrong!\(error)")
                }
            })
        }
        else
        {
            displayAlert("Warning!", message: "Please Enter Email!")
        }
    }
    
    
    //MARK:- Single method to display alert
    func displayAlert(title:String,message:String)
    {
        CustomAlert.showError(self, title:title, subTitle: message, closeButtonTitle:"OK", duration:0.0)
    }
    
    
    
    //MARK:- UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- Creating UI for view
    func setUpInitialUIFromView()
    {
    slideShow.addImagesFromResources(["toppalace.jpg"])
        slideShow.imagesContentMode = UIViewContentMode.ScaleToFill
        slideShow.bringSubviewToFront(backBtn)
        slideShow.bringSubviewToFront(appName)
        slideShow.bringSubviewToFront(enterEmail)
        slideShow.bringSubviewToFront(emailIcon)
        slideShow.bringSubviewToFront(keyIcon)
        
        slideShow.bringSubviewToFront(keyView)
        slideShow.bringSubviewToFront(emailTextField)
        restBtn.layer.cornerRadius = 4.0
        slideShow.bringSubviewToFront(restBtn)
        
        //Display other
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(),
            {
                NSThread.detachNewThreadSelector(Selector("slideViewOfImage"), toTarget:self, withObject:nil)
        })
        
        let placeHolderColor = UIColor.whiteColor()
        emailTextField.attributedPlaceholder  = NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName:placeHolderColor])
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
