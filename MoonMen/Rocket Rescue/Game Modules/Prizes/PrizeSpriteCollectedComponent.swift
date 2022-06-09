//
//  PrizeSpriteCollectedComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 20/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class PrizeSpriteCollectedComponent: GKComponent {

    var prizeSpriteComponent:PrizeSpriteComponent?
    {
        return entity?.component(ofType: PrizeSpriteComponent.self)
    }
    
    func collected()
    {
        let prize = prizeSpriteComponent?.prizeNode
        prize?.hasHit = true
        let game = prize?.game
        let rocket = game?.rescueRocket
        
        let idx = prize?.game?.entities.firstIndex(of: self.entity!)  //remove for the entity array. no more updates
        prize?.game?.entities.remove(at: idx!)
        
        switch (prize?.typeOfPrize)!
        {
        case PrizeType.Health:
            rocket?.currentHitPoints += (prize?.prizeAmount)!
            if (rocket?.currentHitPoints)! > (rocket?.maxHitPoints)!
            {
                rocket?.currentHitPoints = (rocket?.maxHitPoints)!
            }
            let hbar = game?.childNode(withName: "rescueRocketHealthBar") as! HealthBar
            hbar.updateHealthBar(hitPointsRemaining: (rocket?.currentHitPoints)!, maxHitPoints: (rocket?.maxHitPoints)!)
            game?.run((prize?.collectionSound)!)
            prize?.removeFromParent()
            
        case PrizeType.Shield:
            //add shield to rocket for the prizeAmount of time.
            
  /*          let tex = SKTexture(imageNamed: (rocket?.shield)!)
            let shield = SKSpriteNode(texture: tex, color: .clear, size: tex.size())
            shield.zPosition = LayerLevel.BombsLasers
            shield.name = "shield"
            shield.physicsBody = SKPhysicsBody(texture: tex, size: tex.size())
            shield.physicsBody?.affectedByGravity = false
            shield.physicsBody?.categoryBitMask = PhysicsCategory.Shield
            shield.physicsBody?.contactTestBitMask = PhysicsCategory.AlienBombs | PhysicsCategory.Alien
            shield.physicsBody?.collisionBitMask = PhysicsCategory.None
            shield.physicsBody?.pinned = true
            rocket?.addChild(shield)
            game?.run((rocket?.shieldSound)!, withKey: "ssound")
            Timer.scheduledTimer(withTimeInterval: Double((prize?.prizeAmount)!), repeats: false) { (timer) in
                let fade = SKAction.changeVolume(to: 0.0, duration: 0.25)
                game?.run(fade, completion: {
                    game?.removeAction(forKey: "ssound")
                    shield.removeFromParent()
                })
            } */
            rocket?.addShield(prizeAmount: (prize?.prizeAmount)!)
            prize?.removeFromParent()
        case PrizeType.DoubleCannons:
 //           print("double cannon")
            // set the rescue rocket bool flag for double cannon
            rocket?.doubleCannonOn = true
            // set timeer for the flag to be returned to false, ie turn off double cannon
            Timer.scheduledTimer(withTimeInterval: Double((prize?.prizeAmount)!), repeats: false) { (timer) in
                rocket?.doubleCannonOn = false
            }
            game?.run((prize?.collectionSound)!)
            prize?.removeFromParent()
            
        case PrizeType.BigBomb:
            // set the rescue rocket bool flag for upsizing the bomb
            rocket?.bigBombOn = true
            // set timeer for the flag to be returned to false, ie turn off big bomb
            game?.run((prize?.collectionSound)!)
            Timer.scheduledTimer(withTimeInterval: Double((prize?.prizeAmount)!), repeats: false) { (timer) in
                rocket?.bigBombOn = false
            }
            prize?.removeFromParent()
        }
        
    }
}
