//
//  EMMainViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 12/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit
import Parse
class EMMainViewController: UIViewController
{
    var mainView:EMHomeViewController?
    var listView :EMListViewController?
    var isInitialView  = Bool()
    var storyBoard = UIStoryboard()
    @IBOutlet var diffView: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setMainUI()
    }
    
    
    func animateRight()
    {
        isInitialView = true
        if (listView != nil)
        {
            listView!.view .removeFromSuperview()
            listView =  nil
        }
        storyBoard = UIStoryboard(name:"Main", bundle:nil)
        listView = (storyBoard.instantiateViewControllerWithIdentifier("EMListViewController")) as? EMListViewController
        listView!.setHomeViewController(self)
        diffView.addSubview(listView!.view)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.mainView!.view.frame = CGRectMake(self.mainView!.view.frame.origin.x+260,self.mainView!.view.frame.origin.y, self.mainView!.view.frame.size.width, self.mainView!.view.frame.size.height)
        })
        mainView?.view.userInteractionEnabled = true
    }
    
    
    func animateLeft()
    {
        isInitialView = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.mainView!.view.frame = CGRectMake(self.mainView!.view.frame.origin.x-260,self.mainView!.view.frame.origin.y, self.mainView!.view.frame.size.width, self.mainView!.view.frame.size.height)
        })
    }
    
    
    
    //MARK:- Account
    func moveToAccount()
    {
      performSegueWithIdentifier("MovingToAccount", sender: self)
    }
    
    func moveToHistoricMonuments()
    {
      performSegueWithIdentifier("MovingToMonuments", sender: self)
    }
    
    //MARK:- Logout
    func logoutTheCurrentUser()
    {
        PFUser.logOut()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey:"loggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController!.popToRootViewControllerAnimated(true)
        })
    }
    
    func setMainUI()
    {
        storyBoard = UIStoryboard(name:"Main", bundle:nil)
        mainView = (storyBoard.instantiateViewControllerWithIdentifier("EMHomeViewController")) as? EMHomeViewController
        mainView!.setHomeViewController(self)
        mainView?.view.layer.shadowColor = UIColor.blackColor().CGColor
        mainView?.view.layer.shadowOpacity = 1.5
        mainView?.view.layer.shadowRadius = 5.0
        mainView?.view.layer.shadowOffset = CGSize(width:3.0, height: 2.0)
        view.addSubview(mainView!.view)
    }
}

    