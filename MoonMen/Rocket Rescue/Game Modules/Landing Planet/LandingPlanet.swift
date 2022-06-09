//
//  LandingPlanet.swift
//  MoonMen
//
//  Created by Christopher Bunn on 14/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit

class LandingPlanet: SKSpriteNode {
    
    var yOffScreen:CGFloat?
    var yOnScreen:CGFloat?
    var landingPadSprite:SKSpriteNode?
    weak var game:GameScene?
    
    var rescueAliensActions = [RescuedAlienTuple]()
    
    func configure(planet: Dictionary<String, String>)
    {
        let tex  = SKTexture(imageNamed: planet["image"]!)
        self.texture = tex
        self.size = tex.size()
                
        yOffScreen = self.position.y //current off screen position
        yOnScreen  = self.size.height/2
        
        landingPadSprite = self.childNode(withName: "//landingPadSprite") as? SKSpriteNode
        
        let tex2 = SKTexture(imageNamed: planet["landingPad"]!)
        landingPadSprite?.texture = tex2
        landingPadSprite?.size = tex2.size()
        
        let pb = SKPhysicsBody(texture: tex2, size: tex2.size())
        pb.categoryBitMask = PhysicsCategory.LandingPad
        pb.collisionBitMask = PhysicsCategory.None
        pb.contactTestBitMask = PhysicsCategory.RescueRocket
        pb.isDynamic = false
        pb.allowsRotation = true
        landingPadSprite?.physicsBody = pb
        
        // configure in the crash line, this line is where bombs explode, rocket explodes and landing pads are added.
        
        var spoints = [CGPoint(x: tex.size().width / -2, y: tex.size().height * 0.15),
                       CGPoint(x: tex.size().width / 2, y: tex.size().height * 0.15)]
        let crashLine = SKShapeNode(splinePoints: &spoints, count: spoints.count)
        crashLine.name = "crashLine"
        crashLine.lineWidth = 0.0
        crashLine.physicsBody = SKPhysicsBody(edgeChainFrom: crashLine.path!)
        crashLine.physicsBody?.affectedByGravity = false
        crashLine.physicsBody?.categoryBitMask = PhysicsCategory.CrashLine
        crashLine.physicsBody?.contactTestBitMask = PhysicsCategory.AlienBombs | PhysicsCategory.FriendBombs | PhysicsCategory.RescueRocket
        
        self.addChild(crashLine)
        
        //add in the landing pad.
        
//        let lpPosition = CGPointFromString(planet["landingPadPosition"]!)
//        let px = CGFloat(lpPosition.x)
        
        let randomFloat = CGFloat.random(in: -0.50..<0.75) //for now this is hard coded, this needs to be set to a soft setting, the setting are in the plist but need updaing.
        
        let lpos = CGPoint(x: self.size.width / 2 * randomFloat,  //lpPosition.x,
                           y: tex.size().height * 0.25)

        landingPadSprite?.position = lpos
        
        //configure the aliens to be rescued in the mission
        let rescueAliens = planet["rescueAliensPackage"]
        
        let file = Bundle.main.path(forResource: GameConfiguration.RescuePackage, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! Dictionary <String, Any>
        let rescueList = contents[rescueAliens!] as! Array <String>
        
        var delay:Double = 0.0
        for i in rescueList
        {
            let ta = SKTextureAtlas(named: i)
            let names = ta.textureNames.sorted { (str, str2) -> Bool in
                return str < str2
            }
            var texList = [SKTexture]()
            for imageText in names
            {
                texList.append(SKTexture(imageNamed: imageText))
            }
            
            let aRescue = SKSpriteNode(texture: texList.first, color: .clear, size: (texList.first?.size())!)
            aRescue.name = "rescuedAlien"
            
            let xPos = self.size.width / 2 * -0.9
            aRescue.position = CGPoint(x: xPos, y: lpos.y)
            aRescue.zPosition = LayerLevel.Controls
            
            //side to side walking action
            let animate = SKAction.repeatForever(SKAction.animate(with: texList, timePerFrame: 0.2))
            aRescue.run(animate)
            let runPath = SKAction.sequence([SKAction.wait(forDuration: delay), SKAction.fadeIn(withDuration: 0.2), SKAction.move(to: lpos, duration: 3.5), SKAction.fadeOut(withDuration: 0.3)])
            let rescue = SKAction.sequence([runPath])

            rescueAliensActions.append((alien: aRescue, animate: rescue))
            delay += 0.5
        }
    }

// run the rescue animations
    func runRescue()
    {
        //start the alien rescue animation, it stops when all aliens are comleted.
        let sound = SKAudioNode(fileNamed: "alienRescueGiggerJabber.wav")
        sound.autoplayLooped = true
        self.addChild(sound)
        
        // cycle through the list of aliens and start each animation off.
        for (aRescue, anime) in self.rescueAliensActions
        {
            self.addChild(aRescue)
            aRescue.run(anime) {
                aRescue.removeAllActions()
                aRescue.removeFromParent()
                //referencing back through game here to the games scene is not ideal, a better cleaner way needs to be investigated.
                if (aRescue, anime) == self.rescueAliensActions.last!
                {
                    self.game!.landingPlanetStateMachine.enter(LandingPlanetRetractState.self)
                    self.game?.startAliens(aliens: (self.game?.asentAliens!)!)
                    self.game?.hideShowControlButtons(hide: false)   // re display the rocket controls
                    self.game?.rescueRocket?.blastOff()
                    sound.run(SKAction.stop())
                    sound.removeFromParent()
                }
            }
        }
    }
    
    deinit {
  //      print("deinit LandingPlanet")
    }
}
