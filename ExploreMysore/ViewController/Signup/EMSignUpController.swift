//
//  EMSignUpController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 05/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse
class EMSignUpController: UIViewController,KASlideShowDelegate,UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate
{
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568
    @IBOutlet var slideShow: KASlideShow!
    @IBOutlet var appName: UILabel!
    @IBOutlet var downArrow: UIButton!
    @IBOutlet var account: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var fNameLName: UIImageView!
    @IBOutlet var email: UIImageView!
    @IBOutlet var password: UIImageView!
    @IBOutlet var confirm: UIImageView!
    @IBOutlet var profile: UIImageView!
    @IBOutlet var signupBtn: UIButton!
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var emailIcon: UIImageView!
    @IBOutlet var passwordIcon: UIImageView!
    @IBOutlet var lockIcon: UIImageView!
    @IBOutlet var profileIcon: UIImageView!
    @IBOutlet var userView: UIView!
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!
    @IBOutlet var confirmView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    @IBOutlet var addprofile: UIButton!
    
    let imageController = UIImagePickerController()
    var isAnimatedUp  = Bool()
    var containsImage = Bool()
    var SuccessSignUp = Bool()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Do any additional setup after loading the view.
        slideShow.delegate = self
        containsImage = false
        SuccessSignUp = false
        setUpInitialUIFromView()
    }
    
    
    //MARK:-Back Action
    @IBAction func backBtnTapped(sender: AnyObject)
    {
        slideShow.stop()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- SignUp Action
    @IBAction func signupBtnTapped(sender: AnyObject)
    {
        if !userNameTextField.text!.isEmpty && !emailTextField.text!.isEmpty &&
        !passwordTextField.text!.isEmpty && !confirmTextField.text!.isEmpty
        {
            if containsImage != false
            {
                if userNameTextField.text!.characters.count < 5
                {
                    displayAlert("Warning!", message:"Username must contain more than 5 characters")
                }
                else if !EMHelper.sharedInstance.isValidEmail(emailTextField.text!)
                {
                    displayAlert("Warning!", message:"Please enter valid email")
                }
                else if passwordTextField.text!.characters.count < 8
                {
                    displayAlert("Warning!", message:"Password must contain more than 8 characters")
                }
                else if !EMHelper.sharedInstance.isPasswordValid(passwordTextField.text!)
                {
                    displayAlert("Warning!", message:"Password should contain one uppercase letter, one number and one special character!")
                }
                else if passwordTextField.text != confirmTextField.text
                {
                    displayAlert("Warning!", message:"Password Mismatch!")
                }
                else
                {
                    ActivityIndicator.shared.startAnimating(view)
                    let profileImageData:NSData = UIImageJPEGRepresentation(profileIcon.image!,1)!
                    let profileImage = PFFile(data: profileImageData)
                    
                    let newUser = PFUser()
                    newUser.username = userNameTextField.text
                    newUser.email = emailTextField.text
                    newUser.password = passwordTextField.text
                    newUser.setObject(profileImage!, forKey:"profile_picture")
                    
                    NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text, forKey: "userPassword")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    // Sign up the user asynchronously
                    newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                        if ((error) != nil)
                        {
                            ActivityIndicator.shared.stopAnimating()
                            self.displayAlert("Error", message:"SomeThing Went Wrong!")
                        }
                        else
                        {
                            ActivityIndicator.shared.stopAnimating()
                            self.SuccessSignUp = true
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.slideShow.stop()
                                EMHelper.sharedInstance.isFromForgotPassword = false
                                EMHelper.sharedInstance.isFromAccount = false

                                EMHelper.sharedInstance.isFromSignUp = true
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                        }
                    })
                }
            }
            else
            {
                displayAlert("Warning!",message:"Please add your profile Pic!")
            }
        }
        else
        {
                displayAlert("Warning!",message:"Please fill all fields !")
        }
   }
    
    //MARK:- Profile Pic Adding Action
    @IBAction func addProfilePicTapped(sender: AnyObject)
    {
        imageController.editing = false
        imageController.delegate = self;
        
        let optionMenu = UIAlertController(title: nil, message:"Choose Your Option", preferredStyle: .ActionSheet)
        var cameraAction = UIAlertAction();
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            cameraAction = UIAlertAction(title:"Camera", style: UIAlertActionStyle.Default)
                { (alert) -> Void in
                    print("Take Photo")
                    self.openCamera()
                }
        }
        else
        {
            print("Camera not available")
        }

        let GalleryAction = UIAlertAction(title:"Gallery", style: .Default, handler:
        {
            (alert: UIAlertAction) -> Void in
            print("Gallery", terminator: "")
            self.openGallery()
        })
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(GalleryAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    //Picking Image from Gallery
    func openGallery()
    {
        imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imageController, animated: true, completion: nil)
    }
    
    
    //Taking New Pic from Camera
    func openCamera()
    {
        self.imageController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(self.imageController, animated: true, completion: nil)
    }
    
    //MARK:-ImagePicker delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
         containsImage = true
         profileIcon.image = image;
         profileIcon.layer.masksToBounds = true
         profileIcon.layer.cornerRadius = profileIcon.frame.size.width/2
         profileIcon.layer.borderColor = UIColor.whiteColor().CGColor
         profileIcon.layer.borderWidth = 1.5
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:-UITextField Delegate Method
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if textField == userNameTextField
        {
            emailTextField .becomeFirstResponder()
        }
        else if textField == emailTextField
        {
            passwordTextField .becomeFirstResponder()
        }
        else if textField == passwordTextField
        {
            confirmTextField .becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if IS_IPHONE_5
        {
            if textField.tag == 40
            {
                //move textfields up
                let myScreenRect: CGRect = UIScreen.mainScreen().bounds
                let keyboardHeight : CGFloat = 216
                UIView.beginAnimations( "animateView", context: nil)
                var needToMove: CGFloat = 0
                
                var frame : CGRect = self.scrollView.frame
                if (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.sharedApplication().statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight))
                {
                    needToMove = (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.sharedApplication().statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
                }
                frame.origin.y = -needToMove + 40
                self.scrollView.frame = frame
                UIView.commitAnimations()
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if IS_IPHONE_5
        {
            if textField.tag == 40
            {
                //move textfields down
                UIView.beginAnimations( "animateView", context: nil)
                var frame : CGRect = self.scrollView.frame
                frame.origin.y = 84
                self.scrollView.frame = frame
                UIView.commitAnimations()
            }
        }
    }
    
    
    //MARK:- Single method to display alert
    func displayAlert(title:String,message:String)
    {
        let CustomAlert =  SCLAlertView()
        if SuccessSignUp != false
        {
            SuccessSignUp = false
            CustomAlert.showSuccess(self, title:title, subTitle:message, closeButtonTitle: "OK", duration: 0.0)
        }
        else
        {
            CustomAlert.showError(self, title:title, subTitle: message, closeButtonTitle:"OK", duration:0.0)
        }
    }
    
    
    //MARK:- Creating UI for view
    func setUpInitialUIFromView()
    {
        slideShow.addImagesFromResources(["toppalace.jpg"])
        slideShow.imagesContentMode = UIViewContentMode.ScaleToFill
        profileIcon.image = UIImage(named: "profile.png")
        userNameTextField.tintColor = UIColor.whiteColor()
        emailTextField.tintColor = UIColor.whiteColor()
        passwordTextField.tintColor = UIColor.whiteColor()
        confirmTextField.tintColor = UIColor.whiteColor()
        
        //Display other
        let delay = 1.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(),
          {
            NSThread.detachNewThreadSelector(Selector("slideViewOfImage"), toTarget:self, withObject:nil)
          })
        
        signupBtn.layer.cornerRadius = 4.0;
        slideShow .bringSubviewToFront(downArrow)
        slideShow .bringSubviewToFront(appName)
        slideShow .bringSubviewToFront(account)
        slideShow .bringSubviewToFront(scrollView)
        slideShow .bringSubviewToFront(fNameLName)
        slideShow .bringSubviewToFront(email)
        slideShow .bringSubviewToFront(password)
        slideShow .bringSubviewToFront(confirm)
        slideShow .bringSubviewToFront(profile)
        slideShow .bringSubviewToFront(signupBtn)
        slideShow .bringSubviewToFront(userIcon)
        slideShow .bringSubviewToFront(emailIcon)
        slideShow .bringSubviewToFront(passwordIcon)
        slideShow .bringSubviewToFront(lockIcon)
        slideShow .bringSubviewToFront(userView)
        slideShow .bringSubviewToFront(emailView)
        slideShow .bringSubviewToFront(passwordView)
        slideShow .bringSubviewToFront(confirmView)
        slideShow .bringSubviewToFront(profileView)
        slideShow .bringSubviewToFront(userNameTextField)
        slideShow .bringSubviewToFront(emailTextField)
        slideShow .bringSubviewToFront(passwordTextField)
        slideShow .bringSubviewToFront(confirmTextField)
        slideShow .bringSubviewToFront(addprofile)

        let placeHolderColor = UIColor.whiteColor()
        userNameTextField.attributedPlaceholder  = NSAttributedString(string:"UserName", attributes:[NSForegroundColorAttributeName:placeHolderColor])
        emailTextField.attributedPlaceholder  = NSAttributedString(string:"Email", attributes:[NSForegroundColorAttributeName:placeHolderColor])
        passwordTextField.attributedPlaceholder  = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName:placeHolderColor])
        confirmTextField.attributedPlaceholder  = NSAttributedString(string:"Confirm Password", attributes:[NSForegroundColorAttributeName:placeHolderColor])
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
