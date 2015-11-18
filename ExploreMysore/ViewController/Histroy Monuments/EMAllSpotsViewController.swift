//
//  EMAllSpotsViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 27/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse

var spotInformation = [PFObject]()

class EMAllSpotsViewController: UIViewController
{
    var selectedSpot:Int!
    var spotStringValue:String!
    var cellIndexpath:Int!
    @IBOutlet var navBarLabel: UILabel!
    @IBOutlet var spotCollectionView: UICollectionView!
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(selectedSpot, terminator: "")
        getParticularSpotInfo()
    }

    @IBAction func backBtnTapped(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //fetch particular spot data from parse
    func fetchParticularSpotDataFromParse(spotInfo:String)
    {
        print(spotInfo)
        // Build a parse query object
        ActivityIndicator.shared.startAnimating(view)

        let query = PFQuery(className:spotInfo)
        // Fetch data from the parse platform
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            // The find succeeded now rocess the found objects into the countries array
            if error == nil
            {
                // Clear existing country data
                spotInformation.removeAll(keepCapacity: true)
                // Add country objects to our array
                if let objects = objects
                {
                    print(objects)
                    spotInformation = Array(objects.generate())
                }
                // reload our data into the collection view
                self.spotCollectionView.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    //Getting particular spot information from the selected Index.
    func getParticularSpotInfo()
    {
        if selectedSpot == 0
        {
           spotStringValue = "Religious"
           navBarLabel.text = "Religious Sites"
        }
        else if selectedSpot == 1
        {
            spotStringValue = "Historical"
            navBarLabel.text = "Historical Monuments"

        }
        else if selectedSpot == 2
        {
            spotStringValue = "Attractions"
            navBarLabel.text = "Attractions"
        }
        fetchParticularSpotDataFromParse(spotStringValue)
    }
}


extension EMAllSpotsViewController:UICollectionViewDataSource,UICollectionViewDelegate
{
    //MARK:- CollectionView Delegate methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spotInformation.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        if IS_IPHONE_5
        {
            return CGSizeMake(140,150)
        }
        return CGSizeMake(170,170)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath:indexPath) as! UpcomingEventsCell
        // Display the event name
        
        if let eventName = spotInformation[indexPath.row]["name"] as? String
        {
            cell.eventName.text = eventName
        }
        
        // Display  event image
        let eventImage = spotInformation[indexPath.row]["spot_imageurl"] as! String
        print(eventImage, terminator: "")
        if eventImage.isEmpty
        {
            let initialThumbnail = UIImage(named:"overview.jpg")
            cell.eventImage.image = initialThumbnail
        }
        else
        {
            ImageLoader.sharedLoader.imageForUrl(eventImage, completionHandler:
                {(image: UIImage?, url: String) in
                    print(image, terminator: "")
                    cell.eventImage.image = image
            })
        }
        
        cell.layer.cornerRadius = 4.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(red: 0.31, green: 0.66, blue: 0.29, alpha: 1).CGColor
        ActivityIndicator.shared.stopAnimating()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        cellIndexpath = indexPath.row
        print(cellIndexpath, terminator: "")
        performSegueWithIdentifier("MovingToSpotDetails", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "MovingToSpotDetails"
        {
            let locationInformation = segue.destinationViewController as! EMSpotDetailsViewController
            locationInformation.spotDetails = spotInformation[cellIndexpath] as PFObject
        }
    }
    
}
