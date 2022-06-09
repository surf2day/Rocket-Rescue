//
//  LeaderBoardViewCellTableViewCell.swift
//  Space Raider
//
//  Created by Christopher Bunn on 30/1/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import UIKit

class LeaderBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    @IBOutlet weak var scoreDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
