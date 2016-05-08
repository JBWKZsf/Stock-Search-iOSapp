//
//  CustomDetailTableCell.swift
//  Stock
//
//  Created by WangZhonghao on 4/17/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit

class CustomDetailTableCell: UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemValue: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
