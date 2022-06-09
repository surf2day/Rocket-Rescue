//
//  AlienCollectionNodeGeometryComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 6/2/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import GameplayKit

extension Int32 {
    var boolValue: Bool { return self != 0 }
}

extension UInt32 {
    var boolValue: Bool { return self != 0 }
}

class AlienCollectionNodeGeometryComponent: GKComponent
{

    var alienCollectionNodeComponent:AlienCollectionNodeComponent?
    {
        return entity?.component(ofType: AlienCollectionNodeComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval)
    {
        
        let collectionNode = alienCollectionNodeComponent?.collectionNode
        let game = collectionNode?.game
        
        if let behaviour = collectionNode?.behaviour
        {
            if (behaviour & AlienBehaviour.Still).boolValue { return }
            
  /*          if ((alien?.bombTimeDelta)! < TimeInterval(2.5))
            {
                alien?.bombTimeDelta += seconds
                return
            } */
            if (behaviour & AlienBehaviour.Straight).boolValue || (behaviour & AlienBehaviour.Incline).boolValue
            {
                var pos = collectionNode?.position
                
                //test if x position has taken collection to start being off screen, if yes reverse direction.
                //note: SKShapeNode does not have a centre anchor point, the 0,0 is lower left.
                
                if collectionNode?.movementDirection == MoveRocketDirection.Right
                {
                    pos?.x += 5
                    if (pos?.x)! + Constants.BoxCollectionHW >= (game?.sceneWidth)! { collectionNode?.movementDirection = MoveRocketDirection.Left }
                }
                else
                {
                    pos?.x -= 5
                    if (pos?.x)! <= 0.0 { collectionNode?.movementDirection = MoveRocketDirection.Right }
                }
                collectionNode?.position = pos!
                return // once done return to avoid further processing
            }
        }
    }
    
}
