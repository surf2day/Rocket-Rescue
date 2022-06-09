//
//  DropShip.swift
//  MoonMen
//
//  Created by Christopher Bunn on 31/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2: SKSpriteNode {
    
    var gameScene:GameScene?
//    var dropShipSpriteNode:SKSpriteNode?
    var xPos:CGFloat?
    var yOffScreen:CGFloat? //position when drop ship is waiting off screen
    var yOnScreen:CGFloat? //position when ship is on screen releasing or collecting
    var joint:SKPhysicsJointPin? = nil //physics joint for rescue rocket
    var tractorBeam:String?
    
    var missionComplete:Bool = false  //this is set to true when the rocket has docked and the stage is complete ie WON.  
    
    //sets up the dropship and puts it on the screen
    init(image: String, gameScene:GameScene)
    {
        let texture = SKTexture(imageNamed: image)
        super.init(texture: texture, color: UIColor.clear, size:texture.size())
        let w = UIApplication.shared.keyWindow
        let topPadding = w?.safeAreaInsets.top
        
        xPos = gameScene.size.width / 2
        yOffScreen = gameScene.size.height + self.size.height + 150 //to cater for the rescueRocket and tractor beam, this will need to be updated to be a soft setting
        yOnScreen = gameScene.size.height - self.size.height / 2 - topPadding! - 20.0 // xtra to put a gap at the top.
        
         // place in the middle of x axis, off the top of the screen.  the animate down on the screen and drop the rescue ship.
        self.position = CGPoint(x: xPos!, y: yOffScreen!)
        
        self.name = "dropShip2"
        self.zPosition = LayerLevel.Planets
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.DropShip
        self.physicsBody?.collisionBitMask = 0
    }
    
    func attachedRocket(rescueRocket: RescueRocket)
    {
        let xPos:CGFloat = 0.0
        let yPos = -self.size.height / 2 - rescueRocket.size.height / 2
        let anchor = self.convert(CGPoint(x: xPos, y: yPos), to: self.scene!)
        
        rescueRocket.position = anchor
        joint = SKPhysicsJointPin.joint(withBodyA: (self.physicsBody)!,
                                            bodyB: (rescueRocket.physicsBody)!,
                                            anchor: anchor)
        scene?.physicsWorld.add(joint!)
    }
    
    func releaseRocket()
    {
        //before breaking the joint, remove physics is dynamic to false.  we dont want once separated either rocket of dropship using physics.
        // the rate of drop on the rocket will be governed by the frame rate.
   
        
        scene?.physicsWorld.remove(self.joint!)
        joint = nil
    }
    
    func addTractorBeam()
    {
        //creat a sprite for the tractor beam and add to the base of the dropship.
        
        let tex = SKTexture(imageNamed: self.tractorBeam!)
        let tractorBeam = SKSpriteNode(texture: tex, size: tex.size())
        tractorBeam.name = "TractorBeamSpriteNode"
        let xPos:CGFloat = 0.0
        let yPos:CGFloat = -self.size.height
        tractorBeam.position = CGPoint(x: xPos, y: yPos)
        tractorBeam.zPosition = LayerLevel.Beam
        
        //add a line at the bottom of the tractor beam cone that the rocket need to touch to be recovered. anything appart from this curved line is a crash.
        var splinePoints = [CGPoint(x: -tractorBeam.size.width / 2      , y: -tractorBeam.size.height / 2),
                            CGPoint(x: -tractorBeam.size.width / 2 * 0.25, y: -tractorBeam.size.height / 2 * 0.80),
                            CGPoint(x: tractorBeam.size.width  / 2 * 0.25, y: -tractorBeam.size.height / 2  * 0.80),
                            CGPoint(x: tractorBeam.size.width / 2       , y: -tractorBeam.size.height / 2)]
        let line = SKShapeNode(splinePoints: &splinePoints, count: splinePoints.count)
        line.name = "TractorBeamShapeNode"
        line.lineWidth = 0
        line.fillColor = .clear
        line.strokeColor = .clear
        
        line.physicsBody = SKPhysicsBody(edgeChainFrom: line.path!)
        line.physicsBody?.isDynamic = false
        line.physicsBody?.categoryBitMask = PhysicsCategory.TrackorBeam
        line.physicsBody?.contactTestBitMask = PhysicsCategory.RescueRocket
        tractorBeam.addChild(line)
        
        self.addChild(tractorBeam)
    }
    
    func applyTractorBeam(rescueRocket: RescueRocket, tractorBeam: SKSpriteNode, dropShipStateMachine: GKStateMachine )
    {
        // animate rocket nose to the top center of the tractor beam.
        let h = -(rescueRocket.size.height - tractorBeam.size.height) / 2
        
        let pt1 = CGPoint(x: 0.0, y: h)
        let pt = tractorBeam.convert(pt1, to: self.scene!)
        let action = SKAction.move(to: pt, duration: 0.5)
        
        //add a joint for animation off the screen
        
        rescueRocket.run(action, completion: { [weak self] in
            let xPos:CGFloat = 0.0
            let yPos:CGFloat = 0.0 //rescueRocket.size.height / 2
            let jp = rescueRocket.convert(CGPoint(x: xPos, y: yPos), to: (self?.scene!)!)
            let joint = SKPhysicsJointPin.joint(withBodyA: (self?.physicsBody!)!, bodyB: rescueRocket.physicsBody!, anchor: jp)
            self?.scene?.physicsWorld.add(joint)
            self?.missionComplete = true   //mission complete after rocket recovered
            rescueRocket.removeShield()
            
            dropShipStateMachine.enter(DropShip2RetractState.self)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
  //      print("deinit - dropship")
    }
    
}



