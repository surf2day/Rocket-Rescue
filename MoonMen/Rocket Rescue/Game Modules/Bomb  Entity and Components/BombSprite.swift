//
//  BombSpriteComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 21/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class BombSprite: SKSpriteNode
{
    var damagePoints:Int?
    var decentRate:CGFloat?   // this distance travelled each hame (update cycle)
    var explodeSound:SKAction?  //only play when hitting rescue rocket
    var explodeImage:SKTexture?
    var explodeImageFlying:SKTexture
    var hasHit:Bool = false
    var laserReleaseSound:SKAction?
    
    weak var game:GameScene?
    weak var owner:GKEntity? 
    
  //  init(image: String, game: GameScene, bombType:String, AlienORFriend:PhysicsCategory)
    init(game: GameScene, bombType:String, AlienORFriend:UInt32, spriteName:String)
    {
        self.game = game
        let file = Bundle.main.path(forResource: GameConfiguration.BombsFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let bombDict = contents[bombType] as! Dictionary <String,Any>
        damagePoints = bombDict["damagePoints"] as? Int
        decentRate = bombDict["decentRate"] as? CGFloat
        explodeSound = SKAction.playSoundFileNamed((bombDict["explodeSound"] as? String)!, waitForCompletion: false)
        explodeImage = SKTexture(imageNamed: bombDict["explodeImage"] as! String)
        explodeImageFlying = SKTexture(imageNamed: bombDict["explodeImageFlying"] as! String)
        
        if let laserSound = bombDict["releaseSound"] as? String
        {
            laserReleaseSound = SKAction.playSoundFileNamed(laserSound, waitForCompletion: false)
        }
        else
        {
            laserReleaseSound = nil
        }

        let tex = SKTexture(imageNamed: bombDict["image"] as! String)
        
        super.init(texture: tex, color: UIColor.clear , size: tex.size())
        self.zPosition = LayerLevel.BombsLasers
        self.name = spriteName
        
        self.physicsBody = SKPhysicsBody(texture: tex, size: tex.size())
        self.physicsBody?.affectedByGravity = false
        if AlienORFriend == PhysicsCategory.AlienBombs
        {
            self.physicsBody?.categoryBitMask = PhysicsCategory.AlienBombs
            self.physicsBody?.contactTestBitMask = PhysicsCategory.RescueRocket | PhysicsCategory.CrashLine | PhysicsCategory.Shield | PhysicsCategory.FriendBombs
            self.physicsBody?.collisionBitMask = PhysicsCategory.FriendBombs
        }
        else if AlienORFriend == PhysicsCategory.FriendBombs
        {
            self.physicsBody?.categoryBitMask = PhysicsCategory.FriendBombs
            self.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.AlienBombs | PhysicsCategory.CrashLine
            self.physicsBody?.collisionBitMask = PhysicsCategory.None
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 /*
    deinit {
//        print("bomb deinit")
    }
   */
}
