//
//  CustomNewsTableCell.swift
//  Stock
//
//  Created by WangZhonghao on 4/20/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit

class CustomNewsTableCell: UITableViewCell {

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsContent: UILabel!
   
    @IBOutlet weak var newsSource: UILabel!
    
    @IBOutlet weak var newsDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
