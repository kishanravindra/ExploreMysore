//
//  ActivityIndicator.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 12/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit

class ActivityIndicator: UIView {

    var backgroundView = UIView()
    var activityView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: ActivityIndicator
    {
        struct Static
        {
            static let instance: ActivityIndicator = ActivityIndicator()
        }
        return Static.instance
    }
    
    func startAnimating(view: UIView) {
        backgroundView.frame = view.frame
        backgroundView.center = view.center
        backgroundView.backgroundColor = UIColor.clearColor()
        
        activityView.frame = CGRectMake(0, 0, 80, 80)
        activityView.center = view.center
        activityView.backgroundColor = UIColor(red: 0.22, green: 0.59, blue: 0.28, alpha: 1)
        activityView.clipsToBounds = true
        activityView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(activityView.bounds.width / 2, activityView.bounds.height / 2)
        
        activityView.addSubview(activityIndicator)
        backgroundView.addSubview(activityView)
        view.addSubview(backgroundView)
        
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        backgroundView.removeFromSuperview()
    }

}
