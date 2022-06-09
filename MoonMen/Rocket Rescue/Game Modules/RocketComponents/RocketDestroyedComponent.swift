//
//  RocketDestroyedComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 4/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class RocketDestroyedComponent: GKComponent {
   
    /// A convenience property for the entity's rocket component.
    var geometryComponent:RocketGeometryComponent? {
        return entity?.component(ofType: RocketGeometryComponent.self)
    }
    
    func crashedOnPlanet()
    {
        let rescueRocket = geometryComponent?.geometryNode
        
        if ((rescueRocket?.isDying)!) { return }
        rescueRocket?.isDying = true
        
        guard let idx = rescueRocket?.game?.entities.firstIndex(of: self.entity!) else { return }
        rescueRocket?.game?.entities.remove(at: idx)
        
        let hbar = rescueRocket?.game?.childNode(withName: "rescueRocketHealthBar") as! HealthBar
        rescueRocket?.currentHitPoints = 0 //zero out the health bar
        hbar.updateHealthBar(hitPointsRemaining: (rescueRocket?.currentHitPoints)!, maxHitPoints: (rescueRocket?.maxHitPoints)!)
        
        let pt = rescueRocket?.position
        let explodedImageSize = rescueRocket?.crashedOnPlanetExplosion?.size()
        let startFinishSize = CGSize(width: (explodedImageSize?.width)! * 0.1, height: (explodedImageSize?.height)! * 0.1)
        let explosion = SKSpriteNode(texture: rescueRocket?.crashedOnPlanetExplosion, size: startFinishSize)
        explosion.zPosition = LayerLevel.BombsLasers
        explosion.position = pt!
        rescueRocket?.game?.addChild(explosion)
        
        let scaleUp = SKAction.scale(to: explodedImageSize!, duration: 0.25)
        let rocketScaleDown = SKAction.scale(to: 0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.2)
        
        rescueRocket?.run(rocketScaleDown, completion: {
            rescueRocket?.removeFromParent()
        })
        
        explosion.run(SKAction.sequence([(rescueRocket?.deathCrashSound)!, scaleUp, wait, scaleUp.reversed()]), completion: {
            explosion.removeFromParent()
        })
        
    }
    
    func crashedInSpace()
    {
        let rescueRocket = geometryComponent?.geometryNode
        
        if ((rescueRocket?.isDying)!) { return }
        rescueRocket?.isDying = true
        
        guard let idx = rescueRocket?.game?.entities.firstIndex(of: self.entity!) else { return }
        rescueRocket?.game?.entities.remove(at: idx)
        
        let hbar = rescueRocket?.game?.childNode(withName: "rescueRocketHealthBar") as! HealthBar
        rescueRocket?.currentHitPoints = 0 //zero out the health bar
        hbar.updateHealthBar(hitPointsRemaining: (rescueRocket?.currentHitPoints)!, maxHitPoints: (rescueRocket?.maxHitPoints)!)
        
        let pt = rescueRocket?.position
        let explodedImageSize = rescueRocket?.crashedInSpaceExplosion?.size()
        let startFinishSize = CGSize(width: (explodedImageSize?.width)! * 0.1, height: (explodedImageSize?.height)! * 0.1)
        let explosion = SKSpriteNode(texture: rescueRocket?.crashedInSpaceExplosion, size: startFinishSize)
        explosion.zPosition = LayerLevel.BombsLasers
        explosion.position = pt!
        rescueRocket?.game?.addChild(explosion)
        
        let scaleUp = SKAction.scale(to: explodedImageSize!, duration: 0.25)
        let rocketScaleDown = SKAction.scale(to: 0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.2)
        
        rescueRocket?.run(rocketScaleDown, completion: {
            rescueRocket?.removeFromParent()
        })
        
        explosion.run(SKAction.sequence([scaleUp, wait, scaleUp.reversed()]), completion: {
            explosion.removeFromParent()
        })
        
    }
}
