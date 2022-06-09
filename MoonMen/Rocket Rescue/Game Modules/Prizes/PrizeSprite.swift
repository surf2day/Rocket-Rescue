//
//  PrizeSprite.swift
//  Space Raider
//
//  Created by Christopher Bunn on 19/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class PrizeSprite: SKSpriteNode {
    
    let typeOfPrize:PrizeType
    let path:PrizeTypePath
    weak var game:GameScene?
    weak var owner:GKEntity?
    var deployed:Bool = false // flag to advise when the prise is on screen
    var hasHit:Bool = false
    var collectionSound:SKAction?
    
    //holds the actual prize
    var prizeAmount:Int = 0
    
    init(typeOfPrize:PrizeType, path:PrizeTypePath, prizeAmount:Int, image:String) {
        
        self.typeOfPrize = typeOfPrize
        self.path = path
        self.prizeAmount = prizeAmount
        let tex = SKTexture(imageNamed: image)
        super.init(texture: tex, color: .clear, size: tex.size())
        
        self.name = "Prize-" + typeOfPrize.stringValue()
        self.zPosition = LayerLevel.Rocket
        self.physicsBody = SKPhysicsBody(rectangleOf: tex.size())
        self.physicsBody?.categoryBitMask = PhysicsCategory.Prize
        self.physicsBody?.contactTestBitMask = PhysicsCategory.RescueRocket | PhysicsCategory.BounceLine
        self.physicsBody?.collisionBitMask = PhysicsCategory.Alien | PhysicsCategory.AlienBombs
        self.physicsBody?.affectedByGravity = false
        
        //modify the physics to suit the specific type.  The above is standard for most of the prizes
        
        if path == PrizeTypePath.Bounce
        {
            self.physicsBody?.affectedByGravity = true
            self.physicsBody?.restitution = 0.8
            self.physicsBody?.linearDamping = 0
            self.physicsBody?.friction = 0.5
            self.physicsBody?.mass = 0.5
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.collisionBitMask = PhysicsCategory.BounceLine
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("prise deinit - \(String(describing: self.name))")
    }
}

