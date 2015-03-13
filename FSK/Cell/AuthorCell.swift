//
//  AuthorCell.swift
//  FSK
//
//  Created by 黄伟华 on 15/3/11.
//  Copyright (c) 2015年 黄伟华. All rights reserved.
//

import UIKit

class AuthorCell: UITableViewCell {

    
    @IBOutlet var cus_imageView: UIImageView!
    @IBOutlet var cus_titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.layer.borderColor = UIColor.lightGrayColor().CGColor
//        self.layer.borderWidth = 0.5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
