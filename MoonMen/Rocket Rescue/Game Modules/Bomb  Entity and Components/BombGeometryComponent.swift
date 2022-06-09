//
//  BombGeometryComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 21/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class BombGeometryComponent: GKComponent {

    var bombSpriteComponent:BombSpriteComponent?
    {
        return entity?.component(ofType: BombSpriteComponent.self)
    }
    var timeCounter:TimeInterval = 0.0
    
    //update delta time, controls the rate a decent and ascent on the clock cycle
    //every game cycle, the bomb drop by the rate of decent of the rocket + bomb speed
    override func update(deltaTime seconds: TimeInterval)
    {
//        let leBomba = bombSpriteComponent?.bombNode
//        let contact = leBomba?.physicsBody?.contactTestBitMask
        
        timeCounter += seconds
        if timeCounter < 0.03 { return }
        timeCounter = 0.0
        
        var posY = bombSpriteComponent?.bombNode?.position.y
        let posX = bombSpriteComponent?.bombNode?.position.x
        
        // if the yPos is < 0 remove the bomb from the scene it missed.
        // update this later to collide wiht the drop plant and explode, using collision mask
        if posY! < CGFloat(0.0)
        {
 
            
            // remove the entity from the entity array, seems like a bit of a hack to do it here. should really be done in GameScene but cant find a way
            let idx = bombSpriteComponent?.bombNode?.game?.entities.firstIndex(of: self.entity!)
            bombSpriteComponent?.bombNode?.game?.entities.remove(at: idx!)
            bombSpriteComponent?.bombNode?.removeFromParent() //remove the sprite from the Scene
           
            return
        }
        //call the statement machine or 
        
        posY = posY! + (bombSpriteComponent?.bombNode?.decentRate)!
        bombSpriteComponent?.bombNode?.position = CGPoint(x: posX!, y: posY!)
    }
    
}
