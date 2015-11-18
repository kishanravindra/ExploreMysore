//
//  EMHomeViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 12/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse
var upcomingEvent = [PFObject]()

class EMHomeViewController: UIViewController,WebEngineDelegate,UICollectionViewDelegate,UICollectionViewDataSource
{
    var viewController:EMMainViewController?
    var movedRight = Bool()
    var imageCache = [String : UIImage]()

    //var weatherHelper:EMHelper!
    var weatherHelper = EMHelper()
    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var weatherCondition: UILabel!
    @IBOutlet var humdityLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var upcomingEvents: UILabel!
    @IBOutlet var eventCollectionView: UICollectionView!

    
  
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchWeatherDetails()
        loadCollectionViewData()
    }
    
    //MARK:-Fetch Weather Details Of Mysore
    func fetchWeatherDetails()
    {
        EMWebEngine.sharedInstance.delegate = self
        ActivityIndicator.shared.startAnimating(view)
        EMWebEngine.sharedInstance.getMysoreWeatherDetails()
    }
    
    func setWeatherDetails()
    {
        let todayDate = EMHelper.sharedInstance.FormatDate(NSDate())
        dateLabel.text = todayDate;
        weatherImage.image = EMHelper.sharedInstance.setWeatherImage(weatherHelper.weatherIcon)
        weatherCondition.text =  weatherHelper.weatherDescp
        let humidity = String(weatherHelper.humidity)
        humdityLabel.text = String(format:"Humd: %@ %@",humidity,"%")
        let wind = String(weatherHelper.windSpeed)
        windSpeedLabel.text = String(format:"Wind: %@ Km/h",wind)
        let temparture = String(EMHelper.sharedInstance.convertToCelsius(weatherHelper.temp))
        tempLabel.text = String(format:"Temp: %@°C",temparture)
    }
    
    func loadCollectionViewData()
    {
        // Build a parse query object
        let query = PFQuery(className:"UpcomingEvents")
        
        // Fetch data from the parse platform
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            // The find succeeded now rocess the found objects into the countries array
            if error == nil {
                
                // Clear existing country data
                   upcomingEvent.removeAll(keepCapacity: true)
                
                // Add country objects to our array
                if let objects = objects 
                {
                    print(objects, terminator: "")
                    upcomingEvent = Array(objects.generate())
                }
                
                // reload our data into the collection view
                 self.eventCollectionView.reloadData()
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    // MARK:-UICollectionView Delegate methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingEvent.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UpcomingEventsCell
        
        // Display the event name
        if let eventName = upcomingEvent[indexPath.row]["event_name"] as? String
        {
            cell.eventName.text = eventName
        }
        
        // Display  event image
        let eventImage = upcomingEvent[indexPath.row]["event_Image"] as! String
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
        return cell
    }




    //Setting this controller on main controller
    func setHomeViewController(vc:EMMainViewController)
    {
        viewController = vc
    }
    
    @IBAction func menuBtnTapped(sender: AnyObject)
    {
        if (movedRight == false)
        {
            viewController?.animateRight()
            movedRight = true;
        }
        else
        {
            viewController?.animateLeft()
            movedRight = false;
        }
    }
    
    
    //MARK:- Connection Manager Delegate Methods
    func connectionManagerDidRecieveResponse(pResultDict: NSDictionary)
    {
        ActivityIndicator.shared.stopAnimating()
        let weatherArray:NSArray = pResultDict.objectForKey("weather") as! NSArray
        for weatherDict in weatherArray
        {
            weatherHelper.weatherIcon = weatherDict.objectForKey("icon") as? String
            weatherHelper.weatherDescp = weatherDict.objectForKey("description") as? String

        }
        weatherHelper.humidity = pResultDict.objectForKey("main")?.objectForKey("humidity") as! Int
        weatherHelper.temp = pResultDict.objectForKey("wind")?.objectForKey("deg") as! Int
        weatherHelper.windSpeed = pResultDict.objectForKey("wind")?.objectForKey("speed") as! Int
        weatherHelper.cityName = pResultDict.objectForKey("name") as! String
        setWeatherDetails()
    }
    
    
    func connectionManagerDidFailWithError(error: NSError)
    {
        let alertTest = UIAlertView()
        alertTest.delegate = nil
        alertTest.message = error.localizedDescription + "please try again"
        alertTest.addButtonWithTitle("Ok")
        alertTest.title = "Warning"
        alertTest.show()
    }
}
