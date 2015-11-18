//
//  ListViewCell.swift
//  ExploreMysore
//
//  Created by Ravindra Kishan on 20/10/15.
//  Copyright (c) 2015 Ravindra Kishan. All rights reserved.
//

import UIKit

class ListViewCell: UITableViewCell {

    
    @IBOutlet var listImage: UIImageView!
    @IBOutlet var listName: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var reviewedUserName: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
