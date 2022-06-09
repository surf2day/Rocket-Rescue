//
//  RocketGotHitComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 29/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class RocketGotHitComponent: GKComponent {

    /// A convenience property for the entity's rocket component.
    var geometryComponent:RocketGeometryComponent? {
        return entity?.component(ofType: RocketGeometryComponent.self)
    }
    
    func gotHit(damagePoints: Int, playCollision: Bool)
    {
//        print("rescue rocket hit - \(damagePoints)")
        let rescueRocket = geometryComponent?.geometryNode
        let hbar = rescueRocket?.game?.childNode(withName: "rescueRocketHealthBar") as! HealthBar
        
        rescueRocket?.currentHitPoints -= damagePoints
        hbar.updateHealthBar(hitPointsRemaining: (rescueRocket?.currentHitPoints)!, maxHitPoints: (rescueRocket?.maxHitPoints)!)
        
        if (rescueRocket?.currentHitPoints)! <= 0  // rocket destroyed
        {
            rescueRocket?.game?.missionStatus = MissionStatus.LostRocketDestroyed
        }
        else if playCollision
        {
            // if hit by an alien and not dead play collision sound
            rescueRocket?.run((rescueRocket?.collisionSound)!)
        }
        
    }
}
