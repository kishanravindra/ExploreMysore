//
//  EMReviewsViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 02/11/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Social
import Parse

class EMReviewsViewController: UIViewController
{
    var reviewArray = [String]()
    var reviewedName = [AnyObject]()
    var reviewImage:String?
    var commentString:String?
    var reviewObjectId:String?
    var spotReviewName:String?
    var noSocialNetwork:Bool?
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568
    let borderGreenColor = UIColor(red: 0.31, green: 0.65, blue: 0.29, alpha: 1)
    
    @IBOutlet var reviewsTable: UITableView!
    @IBOutlet weak var commentsbackgroundView: UIView!
    @IBOutlet weak var commentedBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var noOfCharacters: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(reviewArray)
        setInitialUp()
    }
    
    @IBAction func backBtnTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Saving the user comments
    @IBAction func commentedBtnTapped(sender: AnyObject)
    {
        if commentTextView.text.characters.count == 0 || commentTextView.text == "Write Your Review"
        {
           noSocialNetwork = false
           displayAlert("Oops!", message:"Review Field Can't Be Empty")
        }
        else
        {
            let comment = commentTextView.text
            let currentUser = PFUser.currentUser()
            print(currentUser?.username)
            let saveReviweduser = currentUser?.username as! AnyObject
            let reviewQuery = PFQuery(className:"Attractions")
            do
            {
                let reviewObject = try reviewQuery.getObjectWithId(reviewObjectId!)
                ActivityIndicator.shared.startAnimating(view)
                reviewObject.addUniqueObjectsFromArray([comment], forKey: "reviews")
                reviewObject.addUniqueObjectsFromArray([saveReviweduser], forKey: "reviewedUser")
                reviewObject.saveInBackgroundWithBlock
                { (success:Bool, error:NSError?) -> Void in
                    if (success)
                    {
                        print("Success")
                        self.noSocialNetwork = true;
                        self.commentsbackgroundView.hidden = true
                        self.commentsbackgroundView.userInteractionEnabled = true
                        self.reviewsTable.userInteractionEnabled = true
                        self.reviewArray.append(self.commentTextView.text)
                        self.reviewedName.append(saveReviweduser) as? AnyObject
                        self.displayAlert("Thank You!", message:"For Writing Review")
                        self.reviewsTable.reloadData()
                    }
                    else
                    {
                        print("Error")
                        self.noSocialNetwork = false;
                        self.displayAlert("Oops!", message: "Something Went Wrong!")
                    }
                }
            }
            catch
            {
                noSocialNetwork = false;
                displayAlert("Oops!", message: "Something Went Wrong!")
            }
        }
    }
    
    @IBAction func commentedCancelBtnTapped(sender: AnyObject)
    {
        reviewsTable.userInteractionEnabled = true
        commentsbackgroundView.hidden = true
    }
    
    //Setting UI Design
    func setInitialUp()
    {
        commentsbackgroundView.hidden = true
        commentsbackgroundView.layer.cornerRadius = 4.0
        commentsbackgroundView.layer.borderWidth = 2.0
        commentsbackgroundView.layer.borderColor = borderGreenColor.CGColor
        commentedBtn.layer.cornerRadius = 4.0
        cancelBtn.layer.cornerRadius = 4.0
        
        //Setting Toolbar for textView
        let toolBar = UIToolbar(frame: CGRectMake(0, view.bounds.size.height, 320, 44))
        toolBar.barStyle = UIBarStyle.Black
        toolBar.translucent = true
        
        //Creating a flexible space for button
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        //creating anf Adding custom button and adding image to toolbar
        let toolBarBtnImage  = UIImage(named:"right.png")
        let toolBarBtn = UIButton(type:UIButtonType.Custom)
        toolBarBtn.bounds = CGRectMake(0,0,(toolBarBtnImage?.size.width)!,(toolBarBtnImage?.size.height)!)
        toolBarBtn .setImage(toolBarBtnImage, forState: UIControlState.Normal)
        toolBarBtn .addTarget(self, action: "doneWithUIPicker", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Adding custom button to bar button
        let doneBtn = UIBarButtonItem(customView: toolBarBtn)
        
        //Creating an array of BarButtonItem and adding the barbuttomitem
        var btnItems = [UIBarButtonItem]()
        btnItems.append(flexible)
        btnItems.append(doneBtn)
        toolBar.items = btnItems
        toolBar.sizeToFit()
        
        commentTextView.delegate = self
        commentTextView.userInteractionEnabled = true
        commentTextView.inputAccessoryView = toolBar
        
        let tapAnywhere = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tapAnywhere)
    }
    
    func doneWithUIPicker()
    {
        view.endEditing(true)
    }
    
     func dismissKeyboard()
    {
      commentTextView.resignFirstResponder();
    }
}



extension EMReviewsViewController:UITextViewDelegate
{
    //MARK:-Textview Delegate methods
    //Checking if when user starts entering, so  we going to remove the default text
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        if textView == commentTextView
        {
            if commentTextView.text == "Write Your Review"
            {
                commentTextView.text = ""
            }
        }
        return true
    }
    
    //Checking if when user didn't enter anything, so again we going to set it to default text
    func textViewDidEndEditing(textView: UITextView)
    {
        if textView == commentTextView
        {
            if commentTextView.text.characters.count == 0
            {
                commentTextView.text = "Write Your Review"
            }
        }
    }
    
    func textViewDidChange(textView: UITextView)
    {
        if textView == commentTextView
        {
            if commentTextView.text.characters.count == 0 && !commentTextView.isFirstResponder()
            {
                commentTextView.text = "Write Your Review"
            }
        }
        
        let len = textView.text.characters.count
        noOfCharacters.text = "\(140 - len)"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if textView == ""
        {
            return true
        }
        else if textView.text.characters.count - range.length + text.characters.count > 140
        {
            noSocialNetwork = false
            displayAlert("Oops!", message: "You Excedd Maximum Limit")
            return false
        }
        else
        {
            if ((range.location == 0 && text == "") || (range.location == 0 && text == "\n"))
            {
                return true
            }
        }
        return true
    }
}

extension EMReviewsViewController:UITableViewDelegate,UITableViewDataSource
{
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return reviewArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 180
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
     {
        cell.contentView.backgroundColor = UIColor.clearColor()
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 0,tableView.frame.size.width,175))
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = true
        whiteRoundedView.layer.cornerRadius = 4.0
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: ListViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListViewCell
        print(reviewArray)
        cell.listName?.text = reviewArray[indexPath.row]
        
       if reviewedName.count > 0
       {
          cell.reviewedUserName.text = reviewedName[indexPath.row] as? String
       }
       
        
        let imageData = reviewImage
        if imageData?.characters.count > 0
        {
            ImageLoader.sharedLoader.imageForUrl(imageData!, completionHandler:
                {(image: UIImage?, url: String) in
                    print(image)
                    cell.listImage.layer.cornerRadius = cell.listImage.frame.size.width/2
                    cell.listImage.image = image
            })
        }
        else
        {
            cell.listImage.image = UIImage(named:"place_sunset.jpg")
        }
        
        cell.listImage.layer.cornerRadius = 4.0
        cell.listImage.layer.masksToBounds = true
        cell.listImage.layer.borderWidth = 2.0
        cell.listImage.layer.borderColor = borderGreenColor.CGColor
        cell.shareBtn.addTarget(self, action: Selector("shareBtnTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        ActivityIndicator.shared.stopAnimating()

        return cell
    }
 
    //MARK:- Allowing user to share comments of other.
    func shareBtnTapped(sender:UIButton)
    {
        print("Share")
        print("Selected item in row \(sender.tag)")
        
        let button = sender
        let view = button.superview!
        let cell = view.superview as! ListViewCell
        let indexPath = reviewsTable.indexPathForCell(cell)
        let cellIndex = indexPath?.row
        print(indexPath)
        
        let commentInfo  = reviewArray[cellIndex!]
        print(commentInfo)

        let actionSheet = UIAlertController(title: "Share", message: "Choose Option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let facebookBtn = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default)
        { (alertAction) -> Void in
            self.facebookPost(commentInfo, imageUrl:self.reviewImage!)
        }
        
        let TwitterBtn = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default)
        { (alertAction) -> Void in
            self.twitterPost(commentInfo, imageUrl: self.reviewImage!)
        }
        
        let CancelBtn = UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Cancel)
        { (alertAction) -> Void in
                
        }
        actionSheet.addAction(facebookBtn)
        actionSheet.addAction(TwitterBtn)
        actionSheet.addAction(CancelBtn)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
 
    //MARK:- Allowing user to write a comment about the visited spot
     @IBAction func commentBtnTapped(sender: AnyObject)
    {
        print("Comment")
        reviewsTable.userInteractionEnabled = false
        commentsbackgroundView.hidden = false
    }
    
    //MARK:- Twitter Post
    func twitterPost(message:String, imageUrl:String)
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
        {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            controller.setInitialText(message)
            controller.addURL(NSURL(string:imageUrl))
            controller.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.Cancelled:
                    NSLog("result: cancelled")
                    self.noSocialNetwork = false
                    self.displayAlert("Post Cancelled", message:"")

                case SLComposeViewControllerResult.Done:
                    // TODO: ADD SOME CODE FOR SUCCESS
                    NSLog("result: done")
                    self.noSocialNetwork = true
                    self.displayAlert("Posted Successfully", message:"On Your Twitter Timeline")
                }
            }
            self.presentViewController(controller, animated: true, completion:
            { () -> Void in
                // controller is presented... do something if needed
            })
        }
        else
        {
            noSocialNetwork = false
            NSLog("Twitter is not available")
            displayAlert("Oops!,Go To settings", message: "Login to your twitter account")
        }
     }
    
    //MARK:- Facebook post
    func facebookPost(message:String, imageUrl:String)
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
        {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            controller.setInitialText(message)
            controller.addURL(NSURL(string:imageUrl))
            controller.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.Cancelled:
                    self.noSocialNetwork = false
                    self.displayAlert("Post Cancelled", message:"")
                    NSLog("result: cancelled")
                case SLComposeViewControllerResult.Done:
                    // TODO: ADD SOME CODE FOR SUCCESS
                    self.noSocialNetwork = true
                    self.displayAlert("Posted Successfully", message:"On Your Facebook Timeline")
                    NSLog("result: done")
                }
            }
            self.presentViewController(controller, animated: true, completion:
            { () -> Void in
                    // controller is presented... do something if needed
            })
        }
        else
        {
            noSocialNetwork = false
            NSLog("Facebook is not available")
            displayAlert("Oops!,Go To settings", message: "Login to your facebook account")
        }
    }
    
    //MARK:- Single method to display alert
    func displayAlert(title:String,message:String)
    {
        let CustomAlert =  SCLAlertView()
        if noSocialNetwork != false
        {
            noSocialNetwork = true
            CustomAlert.showSuccess(self, title:title, subTitle:message, closeButtonTitle: "OK", duration: 0.0)
        }
        else
        {
            noSocialNetwork = false
            CustomAlert.showError(self, title:title, subTitle: message, closeButtonTitle:"OK", duration:0.0)
        }
    }
}
