//
//  MissionCollectionViewCell.swift
//  Space Raider
//
//  Created by Christopher Bunn on 16/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit

class MissionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var missionName: UILabel!
    
    var name:String?
    {
        didSet
        {
            missionName.text = name
        }
    }
    
    var image:String?
    {
        didSet
        {
            var i = UIImage(named: image!)
            if !completed
            {
                i = self.grayScaleImage(image: i!)
            }
            self.backgroundView = UIImageView(image: i)
        }
    }
    var completed:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 5.0
    }
    
    private func grayScaleImage(image: UIImage) -> UIImage
    {
        let ciiImage = CIImage(image: image)
        let greyscale = ciiImage?.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0.0])
        return UIImage(ciImage: greyscale!)
    }
}
