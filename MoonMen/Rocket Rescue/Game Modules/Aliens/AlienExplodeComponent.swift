//
//  AlienExplodeComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 27/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

extension SKAction {
    class func shake(initialPosition:CGPoint, duration:Float, amplitudeX:Int = 12, amplitudeY:Int = 3) -> SKAction {
        let startingX = initialPosition.x
        let startingY = initialPosition.y
        let numberOfShakes = duration / 0.015
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let newXPos = startingX + CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let newYPos = startingY + CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            actionsArray.append(SKAction.move(to:CGPoint(x:newXPos, y:newYPos), duration: 0.015))
        }
        actionsArray.append(SKAction.move(to:initialPosition, duration: 0.015))
        return SKAction.sequence(actionsArray)
    }
}

class AlienExplodeComponent: GKComponent {
    
    var alienSpriteComponent:AlienSpriteComponent?
    {
        return entity?.component(ofType: AlienSpriteComponent.self)
    }

    //alien hit by a bomb,  deduct the hit points from the alien, <= 0 then run the death sequence
    func alienHit(damagePts: Int)
    {
        let alien = alienSpriteComponent?.alienNode
        
        alien?.hitPoints -= damagePts
        alien?.hasHit = true
        if ((alien?.hitPoints)!) <= 0
        {
            //alien has died and run and explosion etc and disappear
   //         alien?.hasHit = true
            let idx = alien?.game?.entities.firstIndex(of: self.entity!)
            alien?.game?.entities.remove(at: idx!)
            
            alien?.game?.scoreBoard?.addPoints(points: (alien?.scorePoints)!)
            
            //if the alien is part of a collection, the pt of explosion need to be converted to in the scene.
            let pt = alien?.position
            let pt2 = alien?.parent?.convert(pt!, to: (alien?.game!.scene)!)
            
            let explodedImageSize = alien?.explosionImage.size()
            let startFinishSize = CGSize(width: (explodedImageSize?.width)! * 0.1, height: (explodedImageSize?.height)! * 0.1)
            let explosion = SKSpriteNode(texture: alien?.explosionImage, size: startFinishSize)
            explosion.zPosition = LayerLevel.BombsLasers
            explosion.position = pt2!
            explosion.name = "explosion"
            alien?.game?.addChild(explosion)
            
            let scaleUp = SKAction.scale(to: explodedImageSize!, duration: 0.2)
            let alienScaleDown = SKAction.scale(to: 0, duration: 0.1)
            
            alien?.run(alienScaleDown, completion: {
                alien?.removeFromParent()
            })
            
            explosion.run(SKAction.sequence([(alien?.deathSound)!, scaleUp, scaleUp.reversed()]), completion: {
                explosion.removeFromParent()
            })
        }
        else
        {
            //alien still has hit point ie alive, run a impact effect/animation natbe colour chage
            //pluse the alien red and spin it
            
            let hitC = hitColour(col:(alien?.hitColour)!)
            
            let c = SKAction.colorize(with: hitC, colorBlendFactor: 1.0, duration: 0.1)
            let wait = SKAction.wait(forDuration: 0.15)
            let c2 = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
            let colorChange = SKAction.sequence([c,wait,c2])
            
            let effect = self.hitEffect(effect: (alien?.hitAction)!)
            alien?.run(SKAction.group([(alien?.hitSound)!, colorChange, effect]), completion: {
                alien?.hasHit = false
            })
        }
    }
 
    func hitColour(col:String) -> UIColor
    {
        switch col {
        case "red":    return UIColor.red
        case "orange": return UIColor.orange
        case "green":  return UIColor.green
        case "blue":   return UIColor.blue
        default:
            return UIColor.clear
        }
    }
    
    func hitEffect(effect:String) -> SKAction
    {
        let alien = alienSpriteComponent?.alienNode
        
        switch effect {
            
        case "spin": return SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 0.2)
        case "shake": return SKAction.shake(initialPosition: (alien?.position)!, duration: 0.2, amplitudeX: 24, amplitudeY: 10)
        case "warpBend": return self.warpBend()
            
        default: return SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 0.2)
        }
    }
    
    // MARK: warp routines for bending aliens when hit
    
    func warpBend() -> SKAction
    {
        
        let alien = alienSpriteComponent?.alienNode
        
        let sourcePositions: [simd_float2] = [
            simd_make_float2(0, 0), simd_make_float2(0.5, 0), simd_make_float2(1, 0),
            simd_make_float2(0, 0.5), simd_make_float2(0.5, 0.5), simd_make_float2(1, 0.5),
            simd_make_float2(0, 1), simd_make_float2(0.5, 1), simd_make_float2(1, 1) ]
        
        let destinationPositions: [simd_float2] = [
            simd_make_float2(0, 0), simd_make_float2(0.5, 0.4), simd_make_float2(1, 0),
            simd_make_float2(0.4, 0.5), simd_make_float2(0.5, 0.5), simd_make_float2(0.6, 0.5),
            simd_make_float2(0, 1), simd_make_float2(0.5, 0.6), simd_make_float2(1, 1) ]
        
        let noWarp = SKWarpGeometryGrid(columns: 2, rows: 2)
        let warpGrid = SKWarpGeometryGrid(columns: 2, rows: 2, sourcePositions: sourcePositions, destinationPositions: destinationPositions)
        alien?.warpGeometry = noWarp
        
        let warpAction = SKAction.animate(withWarps: [noWarp, warpGrid, noWarp, warpGrid, noWarp], times: [0.1, 0.2, 0.3, 0.4, 0.5])
        
        return warpAction!
        
    }
}
