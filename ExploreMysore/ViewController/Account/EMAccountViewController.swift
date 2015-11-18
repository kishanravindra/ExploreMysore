//
//  EMAccountViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 21/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse
var accountDetails = [PFObject]()

class EMAccountViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568
    let borderGreenColor = UIColor(red: 0.31, green: 0.65, blue: 0.29, alpha: 1)
    let imageController = UIImagePickerController()

    @IBOutlet var userName: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var showPasswordBtn: UIButton!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var curPaswwordLabel: UILabel!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var resetPasswordView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var editPic: UIButton!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmNewPasswordTextField: UITextField!
    var passwordShown:Bool!
    var updateSuccess:Bool!


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        passwordShown = false
        updateSuccess = false
        setAccountUI()
        loadUserData()
    }

    @IBAction func backBtnTapped(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK:- Show and Hide Password
    @IBAction func showPasswordBtnTapped(sender: AnyObject)
    {
        if !passwordShown
        {
           passwordTextField.secureTextEntry = false
           showPasswordBtn .setTitle("Hide Password", forState: UIControlState.Normal)
           passwordShown = true
        }
        else
        {
            passwordTextField.secureTextEntry = true
            showPasswordBtn .setTitle("Show Password", forState: UIControlState.Normal)
            passwordShown = false
        }
    }
    
    //MARK:-Edit profile Pic
    @IBAction func editPicBtn(sender: UIButton!)
    {
        let buttonTag:UIButton = sender
        if buttonTag.tag == 10   //ProfilePic Button Action
        {
            print("Edit Pic", terminator: "")
            imageController.editing = false
            imageController.delegate = self;
            
            let optionMenu = UIAlertController(title: nil, message:"Choose Your Option", preferredStyle: .ActionSheet)
            var cameraAction = UIAlertAction();
            //Camera
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
            
            //Gallery
            let GalleryAction = UIAlertAction(title:"Gallery", style: .Default, handler:
                {
                    (alert: UIAlertAction) -> Void in
                    print("Gallery", terminator: "")
                    self.openGallery()
                })
            
            //Cancel
            let CancelAction = UIAlertAction(title:"Cancel", style: .Default, handler:
                {
                    (alert: UIAlertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            optionMenu.addAction(cameraAction)
            optionMenu.addAction(GalleryAction)
            optionMenu.addAction(CancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        else if buttonTag.tag == 20   //Email Button Action
        {
            print("Email", terminator: "")
            emailTextField.userInteractionEnabled = true
            emailTextField.becomeFirstResponder()
        }
        else if buttonTag.tag == 30   //Password Button Action
        {
            print("Password", terminator: "")
            scrollView.userInteractionEnabled = false
            passwordTextField.secureTextEntry = false
            resetPasswordView.hidden = false
        }
    }
    
    //MARK:- Save the new password
    @IBAction func savePasswordBtnPasswordBtnTapped(sender: AnyObject)
    {
        if !newPasswordTextField.text!.isEmpty && !confirmNewPasswordTextField.text!.isEmpty
        {
            if newPasswordTextField.text!.characters.count < 8
            {
               displayAlert("Warning!", message:"Password must contain more than 8 characters")
            }
            else if !EMHelper.sharedInstance.isPasswordValid(newPasswordTextField.text!)
            {
                displayAlert("Warning!", message:"Password should contain one uppercase letter, one number and one special character!")
            }
            else if newPasswordTextField.text != confirmNewPasswordTextField.text
            {
                displayAlert("Warning!",message:"Password Mismatch!")
            }
            else if newPasswordTextField.text == passwordTextField.text
            {
                displayAlert("Warning!",message:"Old Password And New password can't Be Same!")
            }
            else
            {
                ActivityIndicator.shared.startAnimating(view)
                let currentUserNewPassword = PFUser.currentUser()!
                currentUserNewPassword.password = newPasswordTextField.text
                currentUserNewPassword.saveInBackgroundWithBlock
                { (success:Bool, error:NSError?) -> Void in
                    if (success)
                    {
                        ActivityIndicator.shared.stopAnimating()
                        self.updateSuccess = true
                        self.scrollView.userInteractionEnabled = true
                        self.passwordTextField.secureTextEntry = true
                        self.resetPasswordView.hidden = true
                        self.displayAlert("Updated!",message:"Password Successfully!")
                        //self.logoutTheUser()
                        
                        //Display other
                        let delay = 1.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue(),
                            {
                                NSThread.detachNewThreadSelector(Selector("logoutTheUser"), toTarget:self, withObject:nil)
                            })
                    }
                    else
                    {
                        ActivityIndicator.shared.stopAnimating()
                        self.resetPasswordView.hidden = true
                        self.displayAlert("Error!",message:"Something Went Wrong!")
                    }
                }
            }
        }
        else
        {
            displayAlert("Warning!", message:"Both Fields Are Mandatory")
        }
    }
    
    //MARK:- Logout the user ,once he/she changes the password
    func logoutTheUser()
    {
        EMHelper.sharedInstance.isFromAccount = true
        EMHelper.sharedInstance.isFromSignUp = false
        EMHelper.sharedInstance.isFromForgotPassword = false

        PFUser.logOut()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey:"loggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController!.popToRootViewControllerAnimated(true)
        })
    }
    
    //MARK:- Cancel Button Action
    @IBAction func passwordCancelBtnTapped(sender: AnyObject)
    {
        scrollView.userInteractionEnabled = true
        passwordTextField.secureTextEntry = true
        resetPasswordView.hidden = true
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
        profileImage.image = image;
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius  = profileImage.frame.size.width/2
        profileImage.layer.borderColor   = borderGreenColor.CGColor
        profileImage.layer.borderWidth   = 1.5
        self.dismissViewControllerAnimated(true, completion: nil)
        updateUserPicInfo()
    }
    
    
    //MARK:- Updating the UserDetails
    func updateUserPicInfo()
    {
        ActivityIndicator.shared.startAnimating(view)

        //Getting current User
        let userUpdate = PFUser.currentUser()!
        //Getting users new Image
        let updatedProfileImage = UIImageJPEGRepresentation(profileImage.image!, 1)
        if (updatedProfileImage != nil)
        {
            let newImage = PFFile(data: updatedProfileImage!)
            userUpdate.setObject(newImage!, forKey:"profile_picture")
        }
        userUpdate.saveInBackgroundWithBlock
        { (success:Bool, error:NSError?) -> Void in
        
            if (success)
            {
                ActivityIndicator.shared.stopAnimating()
                self.updateSuccess = true
                self.displayAlert("Updated!",message:"Profile Pic Successfully!")
            }
            else
            {
                ActivityIndicator.shared.stopAnimating()
                self.displayAlert("Error!",message:"Something Went Wrong!")
            }
        }

    }
    
    //MARK:- Load User Data
    func loadUserData()
    {
        ActivityIndicator.shared.startAnimating(self.view)
        PFUser.currentUser()!.fetchInBackgroundWithBlock(
        { (currentUser: PFObject?, error: NSError?) -> Void in
            if let user = currentUser as? PFUser
            {
                self.userName.text = user.username
                self.emailTextField.text = user.email
                let passwordString:AnyObject?  = NSUserDefaults.standardUserDefaults().objectForKey("userPassword")
                self.passwordTextField.text = passwordString as? String
                self.loadUserProfilePic()
            }
        })
    }
    
    //MARK:- Load User Profile Pic
    func loadUserProfilePic()
    {
        if let userPicture = PFUser.currentUser()?["profile_picture"] as? PFFile
        {
            userPicture.getDataInBackgroundWithBlock
            { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil)
                {
                    ActivityIndicator.shared.stopAnimating()
                    self.profileImage.layer.masksToBounds = true
                    self.profileImage.layer.cornerRadius  = self.profileImage.frame.size.width/2
                    self.profileImage.layer.borderColor   = self.borderGreenColor.CGColor
                    self.profileImage.layer.borderWidth   = 1.5
                    self.profileImage.image = UIImage(data:imageData!)
                }
            }
        }
    }
    
    //MARK:- Set Initial UI Design
    func setAccountUI()
    {
        resetPasswordView.hidden = true
        resetPasswordView.layer.cornerRadius = 8.0
        resetPasswordView.layer.borderColor = UIColor.whiteColor().CGColor
        resetPasswordView.layer.borderWidth = 1.0
        
        profileImage.image = UIImage(named:"traveller.jpg")
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius  = profileImage.frame.size.width/2
        profileImage.layer.borderColor   = borderGreenColor.CGColor
        profileImage.layer.borderWidth   = 1.5
        
        editPic.layer.cornerRadius = editPic.frame.size.width/2
        editPic.layer.borderWidth = 0.5
        editPic.layer.borderColor = borderGreenColor.CGColor
        backgroundView.layer.cornerRadius = 8.0
        scrollView.layer.cornerRadius = 8.0
        backgroundView.layer.borderColor = self.borderGreenColor.CGColor
        backgroundView.layer.borderWidth = 1.0
        
        let shadowView  = UIView(frame: CGRectMake(16,165, 288,1))
        shadowView.backgroundColor = borderGreenColor
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOpacity = 2.5
        shadowView.layer.shadowRadius = 5.0
        shadowView.layer.shadowOffset = CGSize(width:3.0, height:4.0)
        if IS_IPHONE_5
        {
            shadowView.frame = CGRectMake(0,166,288,1)
        }
        else
        {
            shadowView.frame = CGRectMake(0,182,342,1)
        }
        scrollView .addSubview(shadowView)
        scrollView.bringSubviewToFront(profileImage)
        scrollView.bringSubviewToFront(editPic)
        
        newPasswordTextField.tintColor = UIColor.whiteColor()
        confirmNewPasswordTextField.tintColor = UIColor.whiteColor()
        
        let placeHolderColor = UIColor.whiteColor()
        newPasswordTextField.attributedPlaceholder  = NSAttributedString(string:"New Password", attributes:[NSForegroundColorAttributeName:placeHolderColor])
        confirmNewPasswordTextField.attributedPlaceholder  = NSAttributedString(string:"Confirm New Password", attributes:[NSForegroundColorAttributeName:placeHolderColor])
    }
    
    //MARK:- Single method to display alert
    func displayAlert(title:String,message:String)
    {
        let CustomAlert = SCLAlertView()
        if updateSuccess != false
        {
            updateSuccess = false
            CustomAlert.showSuccess(self, title:title, subTitle:message, closeButtonTitle: "OK", duration: 0.0)
        }
        else
        {
            CustomAlert.showError(self, title:title, subTitle: message, closeButtonTitle:"OK", duration:0.0)
        }
    }
}


//MARK:- UITextFieldDelegate Methods
extension EMAccountViewController:UITextFieldDelegate
{
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField.tag == 10
        {
            if !emailTextField.text!.isEmpty
            {
                ActivityIndicator.shared.startAnimating(view)
                let currentUserNewEmail = PFUser.currentUser()!
                currentUserNewEmail.email = emailTextField.text
                currentUserNewEmail.saveInBackgroundWithBlock
                    { (success:Bool, error:NSError?) -> Void in
                        if (success)
                        {
                            ActivityIndicator.shared.stopAnimating()
                            self.updateSuccess = true
                            self.emailTextField.userInteractionEnabled = false
                            self.displayAlert("Updated!",message:"Email Successfully!")
                        }
                        else
                        {
                            ActivityIndicator.shared.stopAnimating()
                            self.displayAlert("Error!",message:"Something Went Wrong!")
                        }
                }
            }
            else
            {
                displayAlert("Warning!",message:"Email Field Can't Be Empty!")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.tag == 10
        {
            textField .resignFirstResponder()
            return true
        }
        
        else if textField.tag == 20 || textField.tag == 30
        {
             textField.resignFirstResponder()
            if textField == newPasswordTextField
            {
                confirmNewPasswordTextField.becomeFirstResponder()
            }
            return true
        }
        return true
    }

}



