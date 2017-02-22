//
//  DeckTableViewCell.swift
//  SoundDemo
//
//  Created by ngocdm on 2/22/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class DeckTableViewCell: UITableViewCell {
    static let cellIdentifier = "deckCell"

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
