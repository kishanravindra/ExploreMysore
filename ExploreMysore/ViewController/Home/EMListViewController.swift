//
//  EMListViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 12/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit

class EMListViewController: UIViewController
{
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568

    var viewController:EMMainViewController?
    // MARK: - Private
    @IBOutlet weak var listLableView: UITableView!
    private let tableHeaderHeight: CGFloat = 200.0
    private let tableHeaderCutAway: CGFloat = 50.0
    
    private var headerView: ListHeaderView!
    private var headerMaskLayer: CAShapeLayer!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        headerView = listLableView.tableHeaderView as! ListHeaderView
        listLableView.tableHeaderView = nil
        listLableView.addSubview(headerView)
        
        listLableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        listLableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    func updateHeaderView()
    {
        let effectiveHeight = tableHeaderHeight - tableHeaderCutAway/2
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: listLableView.bounds.width, height: tableHeaderHeight)
        
        if listLableView.contentOffset.y < -effectiveHeight
        {
            headerRect.origin.y = listLableView.contentOffset.y
            headerRect.size.height = -listLableView.contentOffset.y + tableHeaderCutAway/2
        }
        
        headerView.frame = headerRect
        
        // cut away
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLineToPoint(CGPoint(x: 0, y: headerRect.height - tableHeaderCutAway))
        headerMaskLayer?.path = path.CGPath
        
    }

    //Setting this controller on home controller
    func setHomeViewController(vc:EMMainViewController)
    {
        viewController = vc
    }
}


extension EMListViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return 9
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if IS_IPHONE_5
        {
            return 40.9
        }
       return 52
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
       let cell: ListViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListViewCell
        
        if IS_IPHONE_5
        {
            cell.listName.font = UIFont(name:"AvenirNext-Medium", size:14)
        }
        else
        {
            cell.listName.font = UIFont(name:"AvenirNext-Medium", size:16)

        }
            switch indexPath.row
            {
             case 0:
                cell.listName.text = "Account"
                cell.listImage.image = UIImage(named:"account.png")

            case 1:
                cell.listName.text = "Historical Monuments & Attractions"
                cell.listImage.image = UIImage(named:"location_new.png")
             
            case 2:
                cell.listName.text = "Commuting"
                cell.listImage.image = UIImage(named:"Car.png")

            case 3:
                cell.listName.text = "Hotels & restaurants"
                cell.listImage.image = UIImage(named:"hotel.png")

            case 4:
                cell.listName.text = "Hospitals & Health Care"
                cell.listImage.image = UIImage(named:"Plus.png")

            case 5:
                cell.listName.text = "Shopping"
                cell.listImage.image = UIImage(named:"shopping.png")

            case 6:
                cell.listName.text = "Entertainment"
                cell.listImage.image = UIImage(named:"entertainment.png")

            case 7:
                cell.listName.text = "Emergency Contacts"
                cell.listImage.image = UIImage(named:"contacts.png")

            case 8:
                cell.listName.text = "Logout"
                cell.listImage.image = UIImage(named:"logout.png")

            default:
                print("Default", terminator: "")

            }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.row
        {
        case 0:
            viewController!.moveToAccount()
            
        case 1:
            viewController!.moveToHistoricMonuments()
            
        case 8:
            viewController!.logoutTheCurrentUser()
            
        default:
            print("Default", terminator: "")
        }
    }
}

extension EMListViewController : UIScrollViewDelegate
{
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        updateHeaderView()
    }
}
