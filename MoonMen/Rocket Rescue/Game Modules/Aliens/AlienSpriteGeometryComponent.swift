//
//  AlienSpriteGeometryComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 3/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienSpriteGeometryComponent: GKComponent {
    
    var alienSpriteComponent:AlienSpriteComponent?
    {
        return entity?.component(ofType: AlienSpriteComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        let alien = alienSpriteComponent?.alienNode
        let game = alien?.game
                
        if alien?.behaviour == AlienBehaviour.Still || alien?.behaviour == AlienBehaviour.Circle { return }
        
        if alien?.behaviour == AlienBehaviour.Straight || alien?.behaviour == AlienBehaviour.Incline
        {
            let pos = alien?.position
            var dy = 0.0
            if alien?.behaviour == AlienBehaviour.Incline { dy = 35.0 }
            
            if (pos?.x)! > (game?.size.width)! - (alien?.size.width)! / 2
            {
                // send alien back on the reverse vector
                let v = CGVector(dx: -100, dy: dy * -1)
                alien?.physicsBody?.velocity = v
            }
            else if (pos?.x)! < (alien?.size.width)! / 2
            {
                let v = CGVector(dx: 100, dy: dy)
                alien?.physicsBody?.velocity = v
            }
            return // once done return to avoid further processing
        }
    }

}
