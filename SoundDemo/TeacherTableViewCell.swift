//
//  TeacherTableViewCell.swift
//  SoundDemo
//
//  Created by ngocdm on 4/5/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class TeacherTableViewCell: UITableViewCell {
    static let cellIdentifier = "teacherCell"
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var btnBookmark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
