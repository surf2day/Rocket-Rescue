//
//  AlienSprite.swift
//  Space Raider
//
//  Created by Christopher Bunn on 25/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class AlienSprite: SKSpriteNode
{
    var hitColour:String
    var bombType:String
    var hitPoints:Int
    var collisionDamagePoints:Int
    var hitSound:SKAction?
    var deathSound:SKAction?
    var behaviour:Int32 = AlienBehaviour.Still  //basic level of alien behaviour, ie no movement
    var hitAction:String
    var explosionImage:SKTexture
    var scorePoints:Int
    var hasHit:Bool = false
    
    var moveOn:SKAction?
    
    weak var game:GameScene?
    weak var owner:GKEntity?
    var bombTimeDelta:TimeInterval = 0
    var bombReleaseInterval:TimeInterval
    
    init(image: String, game: GameScene, alienDict:Dictionary <String,Any>)
    {
        self.game = game
        self.bombType = alienDict["bombType"] as! String
        self.hitPoints = alienDict["hitPoints"] as! Int
        self.hitColour = alienDict["hitColour"] as! String
        self.hitAction = alienDict["hitAction"] as! String
        self.deathSound = SKAction.playSoundFileNamed(alienDict["deathSound"] as! String, waitForCompletion: false)
        self.hitSound = SKAction.playSoundFileNamed(alienDict["hitSound"] as! String, waitForCompletion: false)

        self.collisionDamagePoints = alienDict["collisionDamagePoints"] as! Int
        let tex = SKTexture(imageNamed: image)
        explosionImage = SKTexture(imageNamed: alienDict["explodeImage"] as! String)
        scorePoints = alienDict["scorePoints"] as! Int
        
        let timer = CGPointFromString(alienDict["bombReleaseInterval"] as! String)
        let t = CGFloat.random(in: timer.x...timer.y)
        self.bombReleaseInterval = TimeInterval(exactly: t)!
        
        super.init(texture: tex, color: UIColor.clear, size: tex.size())
        
        self.zPosition = LayerLevel.Aliens
        self.physicsBody = SKPhysicsBody(rectangleOf: tex.size())
        self.physicsBody?.categoryBitMask = PhysicsCategory.Alien
        self.physicsBody?.contactTestBitMask = PhysicsCategory.RescueRocket | PhysicsCategory.FriendBombs | PhysicsCategory.Shield
        self.physicsBody?.collisionBitMask = PhysicsCategory.RescueRocket 
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // set the alien off screen with some random cordinates within in a boundy on the screen
    func  getOffScreenPosition(ascendingDecending:RocketMode) -> CGPoint
    {
        let leftORRight = GKRandomDistribution(lowestValue: 0, highestValue: 100).nextBool()
        
        let randY = GKRandomDistribution(lowestValue: Int(-self.size.height), highestValue: Int((game?.size.height)! + self.size.height))

        let yPos = randY.nextInt()
        var xPos = 0
        if leftORRight == true  //x position > scene width and y < 0
        {
            let randX = GKRandomDistribution(lowestValue: Int((game?.size.width)! + self.size.width) , highestValue: Int((game?.size.width)! + self.size.width * 2))
            xPos = randX.nextInt()
        }
        else // x position < scene width an y < 0
        {
            let randX = GKRandomDistribution(lowestValue: Int(-self.size.width) , highestValue: Int(self.size.width * -2))
            xPos = randX.nextInt()
        }
       self.position = CGPoint(x: xPos, y: yPos)
//       print("offscreen - \(CGPoint(x: xPos, y: yPos))")
        return CGPoint(x: xPos, y: yPos)
    }
    
    // set up the SKAction for animating the alien onto the screen.
    func getOnScreenPt(ascendingDecending:RocketMode) -> CGPoint
    {
        //determine position to appear on screen
        let randOnX = GKRandomDistribution(lowestValue: Int(self.size.width), highestValue: Int((game?.size.width)!) -  Int(self.size.width)).nextInt()

        //if decending position aliens lower if ascending position aliens
        var lowestVal:Int
        var highestVal:Int
        
        if (ascendingDecending == .Decending)
        {
            lowestVal = Int((game?.landingPlanet?.size.height)!) + Int(self.size.height)
            highestVal = Int((game?.size.height)! * 0.7)
        }
        else //between 45 and 80% of the height
        {
            lowestVal = Int((game?.size.height)! * 0.45)
            highestVal = Int((game?.size.height)! * 0.85)
        }
        let randOnY = GKRandomDistribution(lowestValue: lowestVal, highestValue: highestVal).nextInt()

//        print("onscreen - \(CGPoint(x: randOnX, y: randOnY))")
    
        return CGPoint(x: randOnX, y: randOnY)
    }
    
    func getOnScreenPtCircle(ascendingDecending:RocketMode) -> CGPoint
    {
        // with a circle patten xPos need to be indented by the diamater of the circle 100 + 1/2 the alien, estimated at 35 pixels
        let randOnX = GKRandomDistribution(lowestValue: Int(self.size.width) + Int(100.0), highestValue: Int((game?.size.width)!) -  Int(self.size.width) - Int(100.0)).nextInt()
        
        var lowestVal:Int
        var highestVal:Int
        
        if (ascendingDecending == .Decending)
        {
            lowestVal = Int((game?.landingPlanet?.size.height)!) + Int(self.size.height) + 100
            highestVal = Int((game?.size.height)! * 0.7) - 100
        }
        else //between 45 and 80% of the height
        {
            lowestVal = Int((game?.size.height)! * 0.45) + 100
            highestVal = Int((game?.size.height)! * 0.85) - 100
        }
        let randOnY = GKRandomDistribution(lowestValue: lowestVal, highestValue: highestVal).nextInt()
        return CGPoint(x: randOnX, y: randOnY)
    }
    
    func getFlyingPath(startPoint: CGPoint) -> CGPath
    {
        let path = UIBezierPath()
        
        path.move(to: startPoint)
        path.addLine(to: CGPoint(x: (game?.size.width)! - self.size.width / 2 , y: startPoint.y))
        path.addLine(to: CGPoint(x: self.size.width / 2, y: startPoint.y))
        path.addLine(to: startPoint)
        return path.cgPath
    }
    
    func generateCircleAction() -> SKAction
    {
        let centerY = self.position.y
        let centerX = self.position.x - 100.0

        let direction = GKRandomDistribution(lowestValue: 0, highestValue: 100).nextBool()  //true is anti clockwise
        
        let path:CGMutablePath = CGMutablePath()
        path.addRelativeArc(center: CGPoint(x: centerX, y: centerY), radius: 100, startAngle: 0, delta: .pi * 2)
        path.closeSubpath()
        
        let action = SKAction.follow(path, asOffset: false, orientToPath: false, duration: 5.0)
        
        if direction
        {
            return SKAction.repeatForever(action)
        }
        return SKAction.repeatForever(action.reversed())
    }
    
    deinit {
  //      print("alien deinit")
    }
    
}
