//
//  DropShip.swift
//  MoonMen
//
//  Created by Christopher Bunn on 31/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class RescueRocket: SKSpriteNode {
    private var rescueRocketFile:String?
    private var rescueRocketList:[String:[String:String]] = [:]
    
    var imageBooster:String = ""
    var imageStandard:String
    var jointPoint:CGPoint?
    var moveButtonDistance:CGFloat?   // the amount the ship is moved per touch event, left / right for example
    var ascentRate:CGFloat //amount the rocket moves per frame (60 fps)
    var decentRate:CGFloat
    var bosterRate:CGFloat
    var ascendingDecending:RocketMode = RocketMode.Decending
    var bombType:String = ""
    var laserType:String = ""
    var maxHitPoints:Int = 0
    var currentHitPoints:Int = 0
    var lootRecovered:Int = 0
    var peopleRescued:Int = 0
    var collisionHitDamage:Int = 0
    var crashedOnPlanetExplosion:SKTexture?
    var crashedInSpaceExplosion:SKTexture?
    var shield:String = ""  
    var isDying:Bool = false // when rocket has crashed or been destroyed, set true to avoid multiple didBegin's
    
    var bigBombOn:Bool = false // big bomb flag
    var doubleCannonOn:Bool = false // double cannon flag
    
    var collisionSound:SKAction?
    var shieldSound:SKAudioNode?
    var deathCrashSound:SKAction?
    
    weak var owner:GKEntity?
    weak var game:GameScene?
    
    init(image: String) {
        let texture = SKTexture(imageNamed: image)
        self.ascentRate = 0.0
        self.decentRate = 0.0
        self.bosterRate = 0.0
        self.imageStandard = image
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.name = "rescueRocket"
        self.zPosition = LayerLevel.Rocket
  //      self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsBody?.linearDamping = 0.3
        self.physicsBody?.categoryBitMask = PhysicsCategory.RescueRocket
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.AlienBombs | PhysicsCategory.Prize | PhysicsCategory.CrashLine
        self.physicsBody?.collisionBitMask = PhysicsCategory.CrashLine | PhysicsCategory.Alien
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: weak self
    func blastOff()  // turn the rocker on for a short period to simulate a blastoff.
    {
        self.lockInPosition(false)
        let blast = SKAction.run { [weak self] in
            self?.texture = SKTexture(imageNamed: (self?.imageBooster)!)
        }
        let wait = SKAction.wait(forDuration: 0.5)
        let noblast = SKAction.run { [weak self] in
            self?.texture = SKTexture(imageNamed: (self?.imageStandard)!)
        }
        self.run(SKAction.sequence([blast,wait,noblast]), completion:
        {
            self.ascendingDecending = RocketMode.Ascending
        })
    }
    
    deinit {
 //       print("deinit - rescue rocket")
    }
    
    func dropBomb(game: GameScene)
    {
        let bomb = BombSprite(game: game, bombType: self.bombType, AlienORFriend: PhysicsCategory.FriendBombs, spriteName: "bomb")
        let pos = self.position
        let posY = pos.y - self.size.height / 2
        bomb.position = CGPoint(x: pos.x, y: posY)
        
        let bombEntity = GKEntity()
        let spriteComponent = BombSpriteComponent(bombNode: bomb)
        bombEntity.addComponent(spriteComponent)
        let geometryComponent = BombGeometryComponent()
        bombEntity.addComponent(geometryComponent)
        let explodeComponent = BombExplodeComponent()
        bomb.owner = bombEntity   //added to the bomb so when a hit occours, the right component can be called to process the hit
        bombEntity.addComponent(explodeComponent)
        game.addChild(bomb)
        game.entities.append(bombEntity)
    }
    
    func fireLaser(game: GameScene)
    {
        var bombCount = 1
        
        let posY = self.position.y + self.size.height / 2
        let posX = self.position.x
        
        if self.doubleCannonOn
        {
            bombCount = 2
        }
        
        var i = 1
        
        while i <= bombCount
        {
            let bomb = BombSprite(game: game, bombType: self.laserType, AlienORFriend: PhysicsCategory.FriendBombs, spriteName: "laser")
        
            if self.doubleCannonOn && i == 1
            {
                bomb.position = CGPoint(x: posX - bomb.size.width, y: posY)
            }
            else if self.doubleCannonOn && i == 2
            {
                bomb.position = CGPoint(x: posX + bomb.size.width, y: posY)
            }
            else
            {
                bomb.position = CGPoint(x: posX, y: posY)
            }
            
            if self.bigBombOn
            {
                let action = SKAction.scale(by: 4, duration: 0.0)
                bomb.damagePoints = bomb.damagePoints! * 2
                bomb.run(action)
            }
            bomb.run(bomb.laserReleaseSound!)
            
            let bombEntity = GKEntity()
            let spriteComponent = BombSpriteComponent(bombNode: bomb)
            bombEntity.addComponent(spriteComponent)
            let geometryComponent = BombGeometryComponent()
            bombEntity.addComponent(geometryComponent)
            let explodeComponent = BombExplodeComponent()
            bomb.owner = bombEntity   //added to the bomb so when a hit occours, the right component can be called to process the hit
            bombEntity.addComponent(explodeComponent)
            game.addChild(bomb)
            game.entities.append(bombEntity)
            i += 1
        }
    }
    
    func addShield(prizeAmount: Int)
    {
        let tex = SKTexture(imageNamed: self.shield)
        let shield = SKSpriteNode(texture: tex, color: .clear, size: tex.size())
        shield.zPosition = LayerLevel.BombsLasers
        shield.name = "shield"
        shield.physicsBody = SKPhysicsBody(texture: tex, size: tex.size())
        shield.physicsBody?.affectedByGravity = false
        shield.physicsBody?.categoryBitMask = PhysicsCategory.Shield
        shield.physicsBody?.contactTestBitMask = PhysicsCategory.AlienBombs | PhysicsCategory.Alien
        shield.physicsBody?.collisionBitMask = PhysicsCategory.None
        shield.physicsBody?.pinned = true
        self.addChild(shield)
        self.addChild(self.shieldSound!)
        Timer.scheduledTimer(withTimeInterval: Double (prizeAmount), repeats: false) { (timer) in
            let fade = SKAction.changeVolume(to: 0.0, duration: 0.2)
            self.run(fade, completion: {
                self.shieldSound?.removeFromParent()
                shield.removeFromParent()               //currently this does not cause a crash, however it is likely it may in the future when the shield has been already removed when
                                                        // making contact with the tractor beam.
            })
        }
    }
    
    func removeShield()
    {
        
        if let sh = self.childNode(withName: "shield")
        {
            self.shieldSound?.removeFromParent()
            sh.removeFromParent()
        }
    }
    
    func lockInPosition(_ lock: Bool)
    {
        self.physicsBody?.isDynamic = !lock
    }
}
