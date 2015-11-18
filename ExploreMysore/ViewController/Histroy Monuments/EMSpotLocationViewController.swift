//
//  EMSpotLocationViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 30/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}

class EMSpotLocationViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate
{
    @IBOutlet var navBarLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var viewMap: GMSMapView!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    var locationManager = CLLocationManager()
    var spotLocationName:String!
    var mapTasks = MapTasks()
    var locationMarker: GMSMarker!
    var travelMode = TravelModes.driving
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var waypointsArray: Array<String> = []
    var routePolyline: GMSPolyline!
    var markersArray: Array<GMSMarker> = []

    var locationName:String!
    var streetName:String!
    var cityName:String!
    var zipCode:String!
    var countryname:String!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(spotLocationName, terminator: "")
        distanceLabel.hidden = true

        navBarLabel.text = spotLocationName
        //Use one or the other, not both. Depending on what you put in info.plist
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        setLocationSpotOnMap(spotLocationName)
        viewMap.bringSubviewToFront(distanceLabel)

    }
    
    
    @IBAction func backBtnTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- SegmentBar Action for changing maptype
    @IBAction func mapSegmentBartapped(sender: AnyObject)
    {
        switch (segmentControl.selectedSegmentIndex)
        {
        case 0:
            if let polyline = self.routePolyline
            {
                print(polyline)
                clearRoute()
                waypointsArray.removeAll(keepCapacity: false)
            }
            distanceLabel.hidden = true
            setLocationSpotOnMap(spotLocationName)
            
        case 1:
            distanceLabel.hidden = false
            showingDirectionsFromUserLocationToSpot(spotLocationName)
            
        case 2:
            changeMapType()
        
        default:
            print("default", terminator: "")
        }
    }
    
    
    
    // MARK: CLLocationManagerDelegate method implementation
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        locationManager.stopUpdatingLocation()

        let userCoordinate:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(userCoordinate.latitude) \(userCoordinate.longitude)", terminator: "")
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks 
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            // Address dictionary
            print(placeMark.addressDictionary)
           //self.getAddressFromPlaceMark(placeMark)
            
            // Location name
           if let locationName = placeMark.name
           {
                self.locationName = locationName as String
                print(locationName)
            }

            // Street address
            if let street = placeMark.thoroughfare
            {
                self.streetName = street as String
                print(street)
            }
            
            // City
            if let city = placeMark.locality
            {
                self.cityName = city as String
                print(city)
            }
            
            // Zip code
            if let zip = placeMark.postalCode
            {
                self.zipCode = zip as String
                print(zip)
            }
            
            // Country
            //if let country = placeMark.addressDictionary?["Country"]?[0] as? NSString
            if let country = placeMark.country
            {
                self.countryname = country as String
                print(country)
            }
        })
    }
    
    
    func getAddressFromPlaceMark(unsafePlaceMark: CLPlacemark? )->String?
    {
        if let placeMark = unsafePlaceMark
        {
            if let thoroughfare = placeMark.thoroughfare
            {
                print(thoroughfare)
                return thoroughfare
            }
            else if let address=placeMark.addressDictionary?["FormattedAddressLines"]?[0] as? String
            {
                print(address)

                return address
            }
        }
        return nil
    }
    
   func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            viewMap.myLocationEnabled = true
        }
    }
    
    
    //MARK:- Setting Currentlocation on the map
    func setLocationSpotOnMap(spotAddress:String)
    {
        let address = spotAddress
         self.mapTasks.geocodeAddress(address, withCompletionHandler: { (status, success) -> Void in
            if !success
            {
                print(status)
                if status == "ZERO_RESULTS"
                {
                    self.showAlertWithMessage("The location could not be found.")
                }
            }
            else
            {
                let coordinate = CLLocationCoordinate2D(latitude: self.mapTasks.fetchedAddressLatitude, longitude: self.mapTasks.fetchedAddressLongitude)
                self.viewMap.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14.0)
                self.setupLocationMarker(coordinate)
            }
        })
    }
    
    //MARK:- showing direction in map , from user current location to location spot
    func showingDirectionsFromUserLocationToSpot(spotAddress:String)
    {
        let origin = locationName + "," + streetName + "," + cityName + "," + zipCode + "," + countryname
        print(origin, terminator: "")
        self.mapTasks.getDirections(origin, destination:spotLocationName, waypoints: nil, travelMode: self.travelMode, completionHandler:
        { (status, success) -> Void in
            if success
            {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
                self.displayRouteInfo()
            }
            else
            {
                print(status)
            }
        })
    }
    
    //MARK:- options for different map type
      func changeMapType()
     {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.viewMap.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.viewMap.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.viewMap.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    
    // MARK: Custom method implementation
    func showAlertWithMessage(message: String)
    {
        let alertController = UIAlertController(title:"Explore MYsore", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel)
        {
            (alertAction) -> Void in
        }
        alertController.addAction(closeAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setupLocationMarker(coordinate: CLLocationCoordinate2D)
    {
        if locationMarker != nil
        {
            locationMarker.map = nil
        }
        
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = viewMap
        
        locationMarker.title = mapTasks.fetchedFormattedAddress
        locationMarker.appearAnimation = kGMSMarkerAnimationPop
        locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        locationMarker.opacity = 0.75
        
        locationMarker.flat = true
        locationMarker.snippet = "The best place on earth."
    }
    
    
    func configureMapAndMarkersForRoute() {
        viewMap.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.viewMap
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        destinationMarker.title = self.mapTasks.destinationAddress
        
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }
    
    
    func drawRoute()
    {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = viewMap
    }
    
    func clearRoute()
    {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    
    func displayRouteInfo()
    {
        distanceLabel.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
    }
    
    func recreateRoute()
    {
        if let polyline = routePolyline
        {
            print(polyline)
            clearRoute()
            let origin = locationName + "," + streetName + "," + cityName + "," + zipCode + "," + countryname
            print(origin, terminator: "")
            mapTasks.getDirections(origin, destination: spotLocationName, waypoints: waypointsArray, travelMode: travelMode, completionHandler: { (status, success) -> Void in
                
                if success
                {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else
                {
                    print(status)
                }
            })
        }
    }

}
