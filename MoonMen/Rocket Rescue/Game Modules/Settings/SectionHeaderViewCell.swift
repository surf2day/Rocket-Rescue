//
//  SectionHeaderViewCell.swift
//  Space Raider
//
//  Created by Christopher Bunn on 30/1/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import UIKit

class SectionHeaderViewCell: UITableViewCell {
    
    @IBOutlet weak var sectionTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
