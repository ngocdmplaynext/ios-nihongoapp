//
//  TextTableViewCell.swift
//  SoundDemo
//
//  Created by ngocdm on 2/7/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    static let cellIdentifier = "cell"
    
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
