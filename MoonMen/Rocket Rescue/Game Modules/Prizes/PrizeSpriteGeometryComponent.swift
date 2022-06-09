//
//  PrizeSpriteGeometryComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 19/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class PrizeSpriteGeometryComponent: GKComponent {

    var prizeSpriteComponent:PrizeSpriteComponent?
    {
        return entity?.component(ofType: PrizeSpriteComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
        let prize = prizeSpriteComponent?.prizeNode
        let game = prize?.game
        
        if game?.rescueRocket?.ascendingDecending != RocketMode.Ascending { return }  //prizes only come on screen when the rocket is ascending
        
        if (prize?.deployed)! { return } //already on the screen, no action required.
        
        let path = prize?.path
        let t = Float.random(in: 0.25...1.0) //the delay in release
        
        switch path!
        {
        case PrizeTypePath.Hold:
            prize?.deployed = true
            Timer.scheduledTimer(withTimeInterval: Double(t), repeats: false) { (timer) in
                game?.addChild(prize!)
            }
        case PrizeTypePath.Glide:
            prize?.deployed = true
            let randY = GKRandomDistribution(lowestValue: Int((game?.size.height)! * 0.30), highestValue: Int((game?.size.height)! * 0.45)).nextInt()
            let dy = -(prize?.position.y)! + CGFloat(randY)
            var dx:CGFloat = 0.0
            if prize?.position.x == 0
            {
                dx = (game?.size.width)!
            }
            else
            {
                dx = -(game?.size.width)!
            }
            let t2 = Float.random(in: 8.0...10.0)
            let v = CGVector(dx: dx, dy: dy)
            let action = SKAction.move(by: v, duration: Double(t2))
            Timer.scheduledTimer(withTimeInterval: Double(t), repeats: false) { (timer) in
                game?.addChild(prize!)
                prize?.run(action)
            }
            return
        case PrizeTypePath.Bounce:
            prize?.deployed = true
            // a line needs to be drawn for the prize to bounce off
            
            var splinePoints = [CGPoint(x: 0.0, y: 250.0),
                             CGPoint(x: (game?.size.width)!, y: 225.0)]
            let bounceLine = SKShapeNode(splinePoints: &splinePoints, count: splinePoints.count)
            
            bounceLine.name = "bounceLine"
            bounceLine.lineWidth = 0.0
            
            bounceLine.physicsBody = SKPhysicsBody(edgeChainFrom: bounceLine.path!)
            bounceLine.physicsBody?.affectedByGravity = false
            bounceLine.physicsBody?.isDynamic = true
            bounceLine.physicsBody?.mass = 0
            bounceLine.physicsBody?.friction = 0
            bounceLine.physicsBody?.linearDamping = 0
            bounceLine.physicsBody?.restitution = 0.8
            bounceLine.physicsBody?.categoryBitMask = PhysicsCategory.BounceLine
            bounceLine.physicsBody?.collisionBitMask = PhysicsCategory.Prize
            bounceLine.physicsBody?.contactTestBitMask = PhysicsCategory.Prize
            game?.addChild(bounceLine)
            
            Timer.scheduledTimer(withTimeInterval: Double(t), repeats: false) { (timer) in
                game?.addChild(prize!)
            }
            return
        }
    }
}
