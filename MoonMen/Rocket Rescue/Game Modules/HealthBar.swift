//
//  HealthBar.swift
//  Space Raider
//
//  Created by Christopher Bunn on 30/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit

class HealthBar: SKSpriteNode {
    
    func updateHealthBar(hitPointsRemaining: Int, maxHitPoints: Int)
    {
        let borderColor = UIColor.red
        var fillColor   = UIColor.green
        
        let percent:CGFloat = CGFloat(hitPointsRemaining) / CGFloat(maxHitPoints)
        if percent < 0.40
        {
            fillColor = UIColor.orange
        }
        
        let barSize = CGSize(width: 220, height: 25) // update to soft settings once working
        
        UIGraphicsBeginImageContextWithOptions(barSize, true, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        //draw the outline of the bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
        context.stroke(borderRect, width: 2.0)
        
        //draw the internal of the bar, ie the health amout remaining
        fillColor.setFill()
        let barWidth =  (barSize.width - 2) * CGFloat(hitPointsRemaining) / CGFloat (maxHitPoints)
        let barRect = CGRect(x: 1.0, y: 1.0, width: barWidth, height: barSize.height - 2)
        context.fill(barRect)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        self.texture = SKTexture(image: image)
        self.size = barSize
        
    }
    
}
