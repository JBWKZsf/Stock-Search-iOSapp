//
//  CustomFavouriteTableCellTableViewCell.swift
//  Stock
//
//  Created by WangZhonghao on 4/19/16.
//  Copyright © 2016 WangZhonghao. All rights reserved.
//

import UIKit

class CustomFavouriteTableCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var stockValue: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var MarketCap: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
