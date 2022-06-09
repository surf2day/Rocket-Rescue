//
//  AlienCollectionNode.swift
//  Space Raider
//
//  Created by Christopher Bunn on 6/2/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class AlienCollectionNode: SKShapeNode
{
    var entityList:Array<GKEntity> = []
    
    weak var game:GameScene?
    weak var owner:GKEntity?
    
    var movementDirection = MoveRocketDirection.None  // the left right direction of the collection movement,  using rocked enum just for utility
    
    lazy var behaviour:Int32 = AlienBehaviour.Still
    var moveOn:SKAction?
    var alienLoadingPoints:Array <CGPoint> = []
    
    // for box and triange pattens size is the size of the box or triangle sides.
    
    init(patten: Int32, size: CGSize, game: GameScene, ascentDecent: RocketMode)
    {
        self.game = game
        super.init()
        self.name = "alienCollectionNode"
        self.alpha = 0.0
        self.behaviour = patten
        
//        self.fillColor = .red
        self.lineWidth = 0.0
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Collection
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = 0
        
        if (patten & AlienBehaviour.PattenBox).boolValue || (patten & AlienBehaviour.PattenDiamond).boolValue
        {
            let p = CGPath(rect: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height), transform: nil)
            self.path = p
            self.alienLoadingPoints = [CGPoint(x: 0.0, y: 0.0),CGPoint(x: 0.0, y: Constants.BoxCollectionHW),CGPoint(x: Constants.BoxCollectionHW, y: Constants.BoxCollectionHW),CGPoint(x: Constants.BoxCollectionHW,y: 0.0)]
            self.position = self.getOnScreenPtBox(ascendingDecending: ascentDecent)
        }
        else if (patten & AlienBehaviour.PattenTriangle).boolValue  // equilateral triangle
        {
            let h = pow(size.height, 2)
            let a = pow(size.height / 2, 2)
            let b = sqrt(h - a)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0, y: 0.0))
            path.addLine(to: CGPoint(x: size.height / 2.0, y: b))
            path.addLine(to: CGPoint(x: 150, y: 0.0))
            path.addLine(to: CGPoint(x: 0.0, y: 0.0))
            self.path = path.cgPath
            self.position = self.getOnScreenPtBox(ascendingDecending: ascentDecent)
            
            self.alienLoadingPoints.append(contentsOf: [CGPoint(x: 0.0, y: 0.0), CGPoint(x: size.height / 2.0, y: b), CGPoint(x: 150, y: 0.0)])
        }
        else if (patten & AlienBehaviour.PattenLine).boolValue
        {
            let length = game.size.width - size.width //subtract alien width  //hard coded here at 60
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0.0, y: 0.0))
            path.addLine(to: CGPoint(x: length, y: 0.0))
            self.path = path.cgPath
            
            let pos = self.getOnScreenPtBox(ascendingDecending: ascentDecent)
            let startPos = CGPoint(x: size.width / 2.0, y: pos.y)
            self.position = startPos
            
            for i in stride(from: Int(size.width / 2), to: Int(length), by: Int(size.width))
            {
                self.alienLoadingPoints.append(CGPoint(x: i, y: 0))
            }
            movementDirection = MoveRocketDirection.None
        }
        
        var startActions = [SKAction.fadeIn(withDuration: 0.25)]
        if (behaviour & AlienBehaviour.Rotate).boolValue
        {
            let r = SKAction.rotate(byAngle: .pi / 2, duration: 4.0)
            startActions.append(SKAction.repeatForever(r))
        }
        self.moveOn = SKAction.sequence(startActions)
        
        //set starting sideways direction, true is right, false is left
        if (patten & AlienBehaviour.Straight).boolValue || (patten & AlienBehaviour.Incline).boolValue
        {
            let leftORRight = GKRandomDistribution(lowestValue: 0, highestValue: 100).nextBool()
            if leftORRight
            {
                movementDirection = MoveRocketDirection.Right
            }
            else
            {
                movementDirection = MoveRocketDirection.Left
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getOnScreenPtBox(ascendingDecending:RocketMode) -> CGPoint
    {
        // with a box / diamond patten xPos need to be indented by the width of the box 150 (this is fixed) + 1/2 the alien, estimated at 35 pixels
        let randOnX = GKRandomDistribution(lowestValue: Int(Constants.BoxCollectionHW) + Int(100.0), highestValue: Int((game?.size.width)!) -  Int(Constants.BoxCollectionHW) - Int(100.0)).nextInt()
        
        var lowestVal:Int
        var highestVal:Int
        
        if (ascendingDecending == .Decending)
        {
            lowestVal = Int((game?.landingPlanet?.size.height)!) + Int(Constants.BoxCollectionHW) + 30 //alien width
            highestVal = Int((game?.size.height)! * 0.7) - Int(Constants.BoxCollectionHW)
        }
        else //between 45 and 80% of the height
        {
            lowestVal = Int((game?.size.height)! * 0.45) + Int(Constants.BoxCollectionHW)
            highestVal = Int((game?.size.height)! * 0.85) - Int(Constants.BoxCollectionHW)
        }
        let randOnY = GKRandomDistribution(lowestValue: lowestVal, highestValue: highestVal).nextInt()
        return CGPoint(x: randOnX, y: randOnY)
    }
    
    func pinAliens()
    {
        for alien in self.children
        {
            // this is a bit funky, however the objective is to have the to anchor points for both nodes at the same point in the scene.
            //only way i could figure it out given that a SKShapeNode has no size method
            
            let a1 = alien.convert(alien.position, to: self)
            var a2 = alien.convert(a1, to: (self.game?.scene)!)
            a2.x = a2.x - a1.x
            a2.y = a2.y - a1.y
            let a3 = self.convert(alien.position, to: (self.game?.scene)!)
            
            let jt = SKPhysicsJointLimit.joint(withBodyA: self.physicsBody!,
                                              bodyB: alien.physicsBody!,
                                              anchorA: a3,
                                              anchorB: a2)
            jt.maxLength = 0.0
                                              
            self.game?.scene?.physicsWorld.add(jt)
        }
    }
}
