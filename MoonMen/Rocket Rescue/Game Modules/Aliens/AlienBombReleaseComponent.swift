//
//  AlienBombReleaseComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 29/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienBombReleaseComponent: GKComponent {

    var alienSpriteComponent:AlienSpriteComponent?
    {
        return entity?.component(ofType: AlienSpriteComponent.self)
    }
    

    override func update(deltaTime seconds: TimeInterval) {
//        print("BombRelease deltaTime = \(seconds)")
        let alien = alienSpriteComponent?.alienNode
        
        if alien?.bombType == "none" { return }  //none means the alien does not drop bombs
        
        if ((alien?.bombTimeDelta)! < (alien?.bombReleaseInterval)!)
        {
            alien?.bombTimeDelta += seconds
            return
        }
        alien?.bombTimeDelta = 0.0
        let game = alien?.game
                
        let bomb = BombSprite(game: game!, bombType: (alien?.bombType)!, AlienORFriend: PhysicsCategory.AlienBombs, spriteName: "bomb")
        
        let pt = alien?.position
        //if the alien is part of a collection, the pt of explosion need to be converted to in the scene.
       
        let pos = alien?.parent?.convert(pt!, to: (alien?.game!.scene)!)
        
        let posY = (pos?.y)! - (alien?.size.height)! / 2
        bomb.position = CGPoint(x: (pos?.x)!, y: posY)
        // the contact list is changed here to be rescue rocket and landing planet. bomb dropeed by the rescue rocket sets this to be aliens and landing planet.
//        bomb.physicsBody?.categoryBitMask = PhysicsCategory.AlienBombs
//        bomb.physicsBody?.contactTestBitMask = PhysicsCategory.RescueRocket | PhysicsCategory.Planet | PhysicsCategory.FriendBombs | PhysicsCategory.Shield
        
        let bombEntity = GKEntity()
        let spriteComponent = BombSpriteComponent(bombNode: bomb)
        bombEntity.addComponent(spriteComponent)
        let geometryComponent = BombGeometryComponent()
        bombEntity.addComponent(geometryComponent)
        let explodeComponent = BombExplodeComponent()
        bomb.owner = bombEntity   //added to the bomb so when a hit occours, the right component can be called to process the hit
        bombEntity.addComponent(explodeComponent)
        game?.addChild(bomb)
        game?.entities.append(bombEntity)
    }
}
