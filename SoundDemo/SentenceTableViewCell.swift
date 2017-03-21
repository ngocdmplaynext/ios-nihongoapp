//
//  SentenceTableViewCell.swift
//  SoundDemo
//
//  Created by ngocdm on 3/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class SentenceTableViewCell: UITableViewCell {
    static let cellIdentifier = "sentenceCell"
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbRomaji: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
