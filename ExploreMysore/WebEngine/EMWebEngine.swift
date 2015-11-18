//
//  EMWebEngine.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 13/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit

protocol WebEngineDelegate :NSObjectProtocol
{
    func connectionManagerDidRecieveResponse(pResultDict: NSDictionary)
    func connectionManagerDidFailWithError(error:NSError)
}

class EMWebEngine: NSObject,NSURLConnectionDataDelegate,NSURLConnectionDelegate
{
    weak var delegate:WebEngineDelegate?
    var m_cReceivedData = NSMutableData()
    
    
    class var sharedInstance : EMWebEngine
    {
        struct Static
        {
            static let instance : EMWebEngine = EMWebEngine()
        }
        return Static.instance
    }
    
    //MARK:- getting mysore weather details 
    //http://openweathermap.org/api  or https://developer.forecast.io/b
    func getMysoreWeatherDetails()
    {
        let path:String = "http://api.openweathermap.org/data/2.5/weather?q=Mysore,IN&appid=89b7cd685da5329dc5e2967c9ba78eba"
        //let path:String = "https://api.forecast.io/forecast/ad1b54b9bb1c55f71ab3d5638e5b5841/12.3000,76.6500"
        let urlPath: String = path
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
    }
    
    
    
    //MARK:- NSURLConnection Delegate Methods
    func connection(connection: NSURLConnection, didRecieveResponse response: NSURLResponse)  {
        print("Recieved response")
    }
    
    func connection(didReceiveResponse: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        // Recieved a new request, clear out the data object
        // m_cReceivedData = NSMutableData()
        var statusCode:Int
        m_cReceivedData.length = 0
        let httpReponse:NSHTTPURLResponse = response as! NSHTTPURLResponse
        statusCode = httpReponse.statusCode
        print(statusCode)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData)
    {
        // Append the recieved chunk of data to our data object
        m_cReceivedData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        // Request complete, self.data should now hold the resulting info
        // Convert it to a string
        let dataAsString: NSString = NSString(data:m_cReceivedData, encoding: NSUTF8StringEncoding)!
        print(dataAsString)
        // Convert the retrieved data in to an object through JSON deserialization
        let jsonResult: NSDictionary = (try? NSJSONSerialization.JSONObjectWithData(m_cReceivedData, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary!
        
        if delegate != nil
        {
            if (delegate?.respondsToSelector("connectionManagerDidRecieveResponse:") != nil)
            {
                delegate!.connectionManagerDidRecieveResponse(jsonResult)
            }
                
            else
            {
                print("Received data nil when converted to NSString")
                
            }
            
        }
        
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError)
    {
        print("Connection failed.\(error.localizedDescription)")
        
        if delegate != nil
        {
            if (delegate?.respondsToSelector("connectionManagerDidFailWithError:") != nil)
            {
                delegate!.connectionManagerDidFailWithError(error)
            }
        }
        
    }

}
