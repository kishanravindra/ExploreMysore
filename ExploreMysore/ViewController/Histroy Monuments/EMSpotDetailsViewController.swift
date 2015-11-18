//
//  EMSpotDetailsViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 28/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse

class EMSpotDetailsViewController: UIViewController
{
    var spotDetails:PFObject!
    let borderGreenColor = UIColor(red: 0.31, green: 0.65, blue: 0.29, alpha: 1)

    @IBOutlet var backGrnView: UIView!
    @IBOutlet var navBarLabel: UILabel!
    @IBOutlet var mapLocationBtn: UIButton!
    @IBOutlet var spotImageview: UIImageView!
    @IBOutlet var detailView: UITextView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    var spotName:String!
    var spotObjectId:String!
    var imageUrl:String!
    var reviewItems:[String]?
    var reviewUser:[AnyObject]?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(spotDetails)
        setupTheData()
        setRatingStars()
    }

    @IBAction func backBtnTapped(sender: AnyObject)
    {
      navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- Display the spot location on map and showing the transit route to the spot location
    @IBAction func mapLocationBtnTapped(sender: AnyObject)
    {
        performSegueWithIdentifier("MovingToSpotLocation", sender: self)
    }
    
    //MARK:- Allowing user to write there review/comments on the current location spot.
    @IBAction func reviewBtnTapped(sender: AnyObject)
    {
        performSegueWithIdentifier("MovingToReviews", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "MovingToSpotLocation"
        {
            let spotLocation = segue.destinationViewController as! EMSpotLocationViewController
            spotLocation.spotLocationName = spotName
        }
        else if segue.identifier == "MovingToReviews"
        {
            print(reviewItems)
            let reviewController = segue.destinationViewController as! EMReviewsViewController
            reviewController.reviewArray = reviewItems!
            reviewController.reviewedName = reviewUser!
            reviewController.reviewImage = imageUrl
            reviewController.reviewObjectId = spotObjectId
            reviewController.spotReviewName = spotName
        }
    }
    
    
    //Setting Spot details in view
    func setupTheData()
    {
        backGrnView.layer.cornerRadius = 4.0
        backGrnView.layer.borderWidth = 1.0
        backGrnView.layer.borderColor = self.borderGreenColor.CGColor
        backGrnView.clipsToBounds = true
        
        spotObjectId = spotDetails.objectId
        print(spotObjectId)
        spotName = spotDetails.objectForKey("name") as? String
        
        if let array = spotDetails.objectForKey("reviews") as? NSArray
        {
            print(array)
            reviewItems = array as? [String]
        }
        else
        {
            reviewItems = []
        }
        
        if let reviewUserArray = spotDetails.objectForKey("reviewedUser") as? NSArray
        {
            print(reviewUserArray)
            reviewUser = reviewUserArray as [AnyObject]
        }
        else
        {
            reviewUser = []
        }
        
        navBarLabel.text = spotName
        let descrp = spotDetails.objectForKey("description") as! String
        if let addInfo = spotDetails.objectForKey("additional_Info") as? String
        {
            detailView.text = descrp + "\n" + addInfo
        }
        else
        {
            detailView.text = descrp
        }
        
        imageUrl  = spotDetails.objectForKey("spot_imageurl") as! String
        print(imageUrl, terminator: "")
        
        ImageLoader.sharedLoader.imageForUrl(imageUrl, completionHandler:
            {
                (image: UIImage?, url: String) in
                print(image)
                self.spotImageview.image = image
           })
        
        view.bringSubviewToFront(ratingLabel)
        view.bringSubviewToFront(star1)
        view.bringSubviewToFront(star2)
        view.bringSubviewToFront(star3)
        view.bringSubviewToFront(star4)
        view.bringSubviewToFront(star5)
    }
    
    func setRatingStars()
    {
        if let starArray = spotDetails.objectForKey("reviews") as? NSArray
        {
            print(starArray.count)
            switch starArray.count 
            {
            case 0:
                star1.hidden = true
                star2.hidden = true
                star3.hidden = true
                star4.hidden = true
                star5.hidden = true
                
            case 1...10:
                star1.hidden = false
                star2.hidden = true
                star3.hidden = true
                star4.hidden = true
                star5.hidden = true
             
            case 11...20:
                star1.hidden = false
                star2.hidden = false
                star3.hidden = true
                star4.hidden = true
                star5.hidden = true
                
            case 21...30:
                star1.hidden = false
                star2.hidden = false
                star3.hidden = false
                star4.hidden = true
                star5.hidden = true
                
            case 31...40:
                star1.hidden = false
                star2.hidden = false
                star3.hidden = false
                star4.hidden = false
                star5.hidden = true
                
                
            case 41...1000:
                star1.hidden = false
                star2.hidden = false
                star3.hidden = false
                star4.hidden = false
                star5.hidden = false
                
            default:
                print("default")
            }
        }
        else
        {
            star1.hidden = true
            star2.hidden = true
            star3.hidden = true
            star4.hidden = true
            star5.hidden = true
            ratingLabel.text = "No Reviews Yet!"
        }
    }
    
}
