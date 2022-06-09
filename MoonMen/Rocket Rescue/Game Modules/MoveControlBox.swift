//
//  MoveControlBox.swift
//  Space Raider
//
//  Created by Christopher Bunn on 26/2/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import SpriteKit

class MoveControlBox: SKSpriteNode {
    
    func configureButton()
    {        
        switch self.name
        {
        case "leftTopControl":
            self.texture = SKTexture(imageNamed: "leftTop")
        case "leftCentreControl":
            self.texture = SKTexture(imageNamed: "leftCentre")
        case "leftBottomControl":
            self.texture = SKTexture(imageNamed: "leftBottom")
        case "centreTopControl":
            self.texture = SKTexture(imageNamed: "centreTop")
        case "centreCentreControl":
            self.texture = SKTexture(imageNamed: "centreCentre")
        case "centreBottomControl":
            self.texture = SKTexture(imageNamed: "centreBottom")
        case "rightTopControl":
            self.texture = SKTexture(imageNamed: "rightTop")
        case "rightCentreControl":
            self.texture = SKTexture(imageNamed: "rightCentre")
        case "rightBottomControl":
            self.texture = SKTexture(imageNamed: "rightBottom")
            
        default:
            ()
        }
    }

}
