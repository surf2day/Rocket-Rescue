//
//  BombExplodeComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 21/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class BombExplodeComponent: GKComponent
{
    var bombSpriteComponent:BombSpriteComponent?
    {
        return entity?.component(ofType: BombSpriteComponent.self)
    }
    
    //update delta time, controls the rate a decent and ascent on the clock cycle
    //every game cycle, the bomb drop by the rate of decent of the rocket + bomb speed
    override func update(deltaTime seconds: TimeInterval)
    {
        // can use this for adding bomb effects
 //       print("")
    }
    
    // called when a bomb hits landing planet & needs to show an explosion, no sound of explosion
    func bombHit(rescueRocketHit: Bool)
    {
 
        //remove the bomb abs associated compones from the entities array
        let bomb = bombSpriteComponent?.bombNode
        bomb?.hasHit = true
        let idx = bomb?.game?.entities.firstIndex(of: self.entity!)
        bomb?.game?.entities.remove(at: idx!)
        
        let pt = bomb?.position
        let explodeImageSize = bomb?.explodeImage?.size()
        let startFinishSize = CGSize(width: (explodeImageSize?.width)! * 0.1, height: (explodeImageSize?.height)! * 0.1)
        let explosion = SKSpriteNode(texture: bomb?.explodeImage, size: startFinishSize)
        explosion.name = "explosion"
        explosion.anchorPoint = CGPoint(x: 0.5, y: 0)
        explosion.zPosition = LayerLevel.BombsLasers
        explosion.position = pt!
        bomb?.game?.addChild(explosion)
        
        let wait = SKAction.wait(forDuration: 0.25)
        let scaleUp = SKAction.scale(to: explodeImageSize!, duration: 0.25)
        let scaleDown = SKAction.scale(to: startFinishSize, duration: 0.25)
        
        //if the bomb is from alien and hits RR play explosion
        if rescueRocketHit
        {
            bomb?.game?.run((bomb?.explodeSound)!)
        }
        
        explosion.run(SKAction.sequence([scaleUp,wait,scaleDown]), completion: {
            explosion.removeFromParent()
            bomb?.removeFromParent()
        })
       
        
        // remove the entity from the entity array, seems like a bit of a hack to do it here. should really be done in GameScene but cant find a way
        
        //play bomb explosion & remove the bomb 
//        print("bombHit play explosion ")
    }
    
    // called when a bomb is to be removed and not explosion to be displayed, the explosion will be handled by the other body, ie Alien
    func bombRemove()
    {
        let bomb = bombSpriteComponent?.bombNode
        bomb?.hasHit = true
        let idx = bomb?.game?.entities.firstIndex(of: self.entity!)
        bomb?.game?.entities.remove(at: idx!)
        bomb?.removeFromParent()
    }
    
    //called when bomb needs removal and in flight explosion
    func bombRemovalWithExplosion()
    {
        let bomb = bombSpriteComponent?.bombNode
        bomb?.hasHit = true
        let idx = bomb?.game?.entities.firstIndex(of: self.entity!)
        bomb?.game?.entities.remove(at: idx!)
        
        let pt = bomb?.position
        let explodeImageSize = bomb?.explodeImageFlying.size()
        let startFinishSize = CGSize(width: (explodeImageSize?.width)! * 0.1, height: (explodeImageSize?.height)! * 0.1)
        let explosion = SKSpriteNode(texture: bomb?.explodeImageFlying, size: startFinishSize)
        explosion.name = "explosion"
        explosion.anchorPoint = CGPoint(x: 0.5, y: 0)
        explosion.zPosition = LayerLevel.BombsLasers
        explosion.position = pt!
        bomb?.game?.addChild(explosion)
        
        //remove the bomb abs associated compones from the entities array
        
        let wait = SKAction.wait(forDuration: 0.25)
        let scaleUp = SKAction.scale(to: explodeImageSize!, duration: 0.25)
        let scaleDown = SKAction.scale(to: startFinishSize, duration: 0.25)
        explosion.run(SKAction.sequence([scaleUp,wait,scaleDown]), completion: {
            explosion.removeFromParent()
            bomb?.removeFromParent()
        })
    }
}
