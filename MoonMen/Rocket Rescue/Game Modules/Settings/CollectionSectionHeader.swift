//
//  CollectionSectionHeader.swift
//  Space Raider
//
//  Created by Christopher Bunn on 16/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit

class CollectionSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var stageName: UILabel!
    
    var title:String?{
        didSet
        {
            stageName.text = title
        }
    }
    
}
