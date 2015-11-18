//
//  EMHistroicViewController.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 26/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit

class EMHistroicViewController: UIViewController
{
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568

    @IBOutlet var historyTable: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Back Button Action
    //Will move back to previous controller
    @IBAction func backBtnTapped(sender: AnyObject)
    {
        navigationController?.popViewControllerAnimated(true)
    }
}

extension EMHistroicViewController:UITableViewDelegate,UITableViewDataSource
{
    //Setting number of section to appear in the tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    //Setting Row height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
      if IS_IPHONE_5
      {
        return 168
      }
        return 201
    }
    
    //Adding Information to Individual row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
      let cell: ListViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListViewCell
        switch indexPath.row
        {
        case 0:
            cell.listName.text = "Religious Sites"
            cell.listImage.image = UIImage(named:"darkSky_Chamundi.jpg")
            
        case 1:
            cell.listName.text = "Historical Monuments"
            cell.listImage.image = UIImage(named:"Mysore-Temple-at-Somnathpur.jpg")

        case 2:
            cell.listName.text = "Attractions"
            cell.listImage.image = UIImage(named:"place_sunset.jpg")

        default:
            print("default", terminator: "")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
         performSegueWithIdentifier("MovingToAllSpots", sender: self)
         historyTable.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Passing tapped table index tp next controller, to fetch information accordingly
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "MovingToAllSpots"
        {
            let variousSpot:EMAllSpotsViewController  = segue.destinationViewController as! EMAllSpotsViewController
            variousSpot.selectedSpot  = historyTable!.indexPathForSelectedRow!.row
        }
    }
    
}
