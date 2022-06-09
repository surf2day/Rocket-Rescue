//
//  GameScene.swift
//  MoonMen
//
//  Created by Christopher Bunn on 30/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var parentVC:GameViewController?
    
    var gameData:GameData?  //contains the players current game progress and achievements, loaded from file or from GameCenter
    var stageNumber:Int?
    var missionNumber:Int?
    
    var missionData:[String:String]? //level data, it rocket, landing panet and aliens etc
    
    let sceneScaleFactor:CGFloat = 1.81  //this is the standard game scale 1334 / 750  and the scene is adjust to fit this scale depending on the screen size.
    var screenWidth:CGFloat
    {
        return UIScreen.main.bounds.width
    }
    var screenHeight:CGFloat
    {
        return UIScreen.main.bounds.height
    }
    var sceneHeight:CGFloat
    {
        return sceneScaleFactor * screenHeight
    }
    var sceneWidth:CGFloat
    {
        return sceneScaleFactor * screenWidth
    }
    
    private var backgroundData:String?
    private var backgrounds:[String]!
    var scoreBoard:ScoreKeeper?
    
    var entities = [GKEntity]()       //where all the game enties are entered, namely, rescue rocket, aliens, bombs and blasters and special prizes
    var graphs = [String : GKGraph]()
    
    var dropShip2:DropShip2?  // added here to implete statemachine on the drop ship, superceeding DropShip
    var dropShipStateMachine: GKStateMachine!
    var landingPlanetStateMachine:GKStateMachine!  // state machine for the landing planet
    
    var rescueRocket:RescueRocket?  //the rescue rocket sprite/class,   this is added to an GKEntity which uses CKComponents to control movement by game closk, bomb/blaster release and user input control.
    var rescueRocketEntity:GKEntity?
    
    var moveButtonDirectionMask:UInt32 = MoveButtonDirection.None
    var pauseButton:SKSpriteNode?
    
    let fixedDelta:CFTimeInterval = 1.0/60.0  // tenth of a second
    
    //variable for the scrolling background
    var scrollBackground:SKSpriteNode!
    var scrollBackground2:SKSpriteNode!
    var scrollLayer:SKNode!
    var scrollSpeed:CGFloat!
    
    var asentAliens:Array<AlienTuple>?  //array of aliens and GKentities for fast loading at landing/blast off transition
    
    var landingPlanet:LandingPlanet?
    var missionStatus:MissionStatus = MissionStatus.Underway  //when won the mission is complete and go back to launch page for next mission in the stage
    var missionEnded:Bool = false // flag set to indicate mission complete and avoid update continually causing MissionSummaryBanner being added.
        
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad()
    {
        // pause the game when it goes into the background
        let note = NotificationCenter.default
        note.addObserver(self, selector: #selector(returningFromBackGround(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }

    override func didMove(to view: SKView)
    {
//        NSLog("screen size = \(CGSize(width: screenWidth, height: screenHeight))")
//        NSLog("scene size  = \(size)")
        
        //hide the score board and health bar, these will be reveled as drops ship releases rocket
        self.hideScores(hide: true)
        self.lastUpdateTime = 0

        setUpScoreBoard()
        setUpButtons()
        setUpRescueRocket()
        setUpPhysics()
        setUpDropShip2()
        setUpLandingPlanet()
        setUpPauseButton()
        setUpPrizes()
        
        asentAliens = setupAliens(ascentDecent: RocketMode.Ascending)
        let decentAliens = setupAliens(ascentDecent: RocketMode.Decending)  //get an array of aliens for the decent
        
        setUpScrollBackground()  //includes background sound
        dropShipStateMachine.enter(DropShip2WaitState.self)
        startAliens(aliens: decentAliens)
        dropShipStateMachine.enter(DropShip2DeployState.self)
    }
    
    // when the mission is complete switch back to the start scene and present user with the next mission.
    
    func hideScores(hide :Bool)
    {
        let score = childNode(withName: "score")
        let hbar = childNode(withName: "rescueRocketHealthBar")
        let hbarIcon = childNode(withName: "rescueRocketHealthBarIcon")
        
        score?.isHidden = hide
        hbar?.isHidden = hide
        hbarIcon?.isHidden = hide
    }
    
    private func missionCompleteSwitchtoLaunch()
    {
        if missionEnded == true { return }  //if there is a touchUp this summary will be dismissed in the touchup handler
        
        let refNode = MissionResultsSummary(fileNamed: "MissionSummaryBanner")
        refNode.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        refNode.name = "MissionSummaryBanner"
       
        let messageSprite = refNode.childNode(withName: "//backgroundSprite") as! SKSpriteNode
        messageSprite.texture = SKTexture(imageNamed: "missionResultSummary")
        
        let w = messageSprite.size.width * 0.8
        let resultMessageNode = refNode.childNode(withName: "//resultMessage") as? SKLabelNode
        resultMessageNode?.preferredMaxLayoutWidth = w
        
        // update the summary banner with the scores.
        refNode.missionName = (missionData?["name"])!
        refNode.planetImage = (missionData?["image"])!
        
        // add a timeer here to allow time for the rescue rocket explosion effect to complete.
        Timer.scheduledTimer(withTimeInterval: Double(1.25), repeats: false) { (timer) in
            self.addChild(refNode)
        }
        
        var s:Int = 0
        var r:Int = 0
        var l:Int = 0
        var rh:Int = 0
        
        /* Scoring Rules
            Total Score =  Score * remaining health
         
            People Rescused score = people rescued (* remaining health removed)
            when rocket is crashed or destroyed this score = 0
         
            Loot =  loot  ( * remaining health removed)
            when rocket is crashed or destroyed this score = 0
         
         
            Game wide totals
         
            only up date if the scores are higher than the previous ones.
         
        */
        
        switch (missionStatus)
        {
        case MissionStatus.LostCrashedPlanet:   // score = score, resuced = 0, loot = 0
       //     print("crashed planet")
            missionEnded = true
            refNode.resultMessage = "Crashed"
            rescueRocketEntity?.component(ofType: RocketDestroyedComponent.self)?.crashedOnPlanet()
            rh = 0
            s = (scoreBoard?.mainScore)!
            r = 0
            l = 0
        case MissionStatus.LostToSpace: // score = score, resuced = 0, loot = 0
            missionEnded = true
 //           print("lost to Space")
            refNode.resultMessage = "Missed the mother ship..."
            rh = 0
            s = (scoreBoard?.mainScore)!
            r = 0
            l = 0
        case MissionStatus.LostRocketDestroyed: // score = score, resuced = 0, loot = 0
            missionEnded = true
 //           print("rocket destroyed")
            refNode.resultMessage = "Argh those aliens"
            rescueRocketEntity?.component(ofType: RocketDestroyedComponent.self)?.crashedInSpace()
            rh = 0
            s = (scoreBoard?.mainScore)!
            r = 0
            l = 0
        case MissionStatus.Won: // score = score * remaining health, resuced = rescued * remaining health, loot = loot * remaining health
 //           print("mission won")
            missionEnded = true
            refNode.resultMessage = "Success!"
            rh = (rescueRocket?.currentHitPoints)!
            s = (scoreBoard?.mainScore)! * rh
            r = (scoreBoard?.numberRescued)!
            l = (scoreBoard?.lootScore)!
        default:
            break
        }
        
        refNode.score = s
        refNode.loot = l
        refNode.rescued = r
        
        let stage = gameData?.stages[stageNumber!]
        //check there is mission data, if not then, stage does not exist creat a new one
        if !(stage?.missions.indices.contains(missionNumber!))!
        {
            gameData?.stages[stageNumber!].missions.append(GameData.Mission())
        }
        let m = gameData?.stages[stageNumber!].missions[missionNumber!]
        
        if s > (m?.bestScore)!
        {
            gameData?.stages[stageNumber!].missions[missionNumber!].bestScore = s  //update mission score
            gameData?.gameTotalScore += s - (m?.bestScore)! //update game wide store
        }
        if l > (m?.totalLoot)!
        {
            gameData?.stages[stageNumber!].missions[missionNumber!].totalLoot = l //update mission score
            gameData?.gameTotalLoot += l - (m?.totalLoot)! //update game wide store
        }
        if r > (m?.numberRescued)!
        {
            gameData?.stages[stageNumber!].missions[missionNumber!].numberRescued = r //update mission score
            gameData?.gameTotalRescued += r - (m?.numberRescued)! //update game wide store
        }
        
        // this should only be set when missionStatus.Won
        // futher if all missions have been completed that stage needs to also be set to complete
        
        //only save data when a stage is won, which also updates the leader boards
        
        if missionStatus == MissionStatus.Won
        {
            gameData?.stages[stageNumber!].missions[missionNumber!].completed = true
            gameData?.lastSaveDateTime = Date()
            do {
                try GameDataMrg.sharedGameDataMgr.saveGameData(gameData: gameData!)
            }
            catch
            {
                NSLog("Unable to save game data")
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scrollWorld()
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        self.lastUpdateTime = currentTime
        
        if missionStatus != MissionStatus.Underway
        {
            self.missionCompleteSwitchtoLaunch()
        }
        
        //if the rocket has landed, ignore control input until it has taken off
        if rescueRocket?.ascendingDecending == RocketMode.Landed { return }
        
        if moveButtonDirectionMask & MoveButtonDirection.Left != 0  // move Left
        {
            rescueRocketEntity?.component(ofType: RocketPlayerControlComponent.self)?.moveRocket(direction: MoveRocketDirection.Left)
        }
        else if moveButtonDirectionMask & MoveButtonDirection.Right != 0 //move right
        {
            rescueRocketEntity?.component(ofType: RocketPlayerControlComponent.self)?.moveRocket(direction: MoveRocketDirection.Right)
        }
        
        if moveButtonDirectionMask & MoveButtonDirection.Down != 0  // move down
        {
            rescueRocketEntity?.component(ofType: RocketPlayerControlComponent.self)?.moveRocket(direction: MoveRocketDirection.Down)
        }
        else if moveButtonDirectionMask & MoveButtonDirection.Up != 0 //move Up
        {
            rescueRocketEntity?.component(ofType: RocketPlayerControlComponent.self)?.moveRocket(direction: MoveRocketDirection.Up)
        }
        else if moveButtonDirectionMask & MoveButtonDirection.None == 0 //move None
        {
            rescueRocketEntity?.component(ofType: RocketPlayerControlComponent.self)?.moveRocket(direction: MoveRocketDirection.None)
        }
        
        // check to ensure rocket not moving off screen, this is typicall in the event of a collision slinging the rocket off in some direction
        // if it is then adjust x position to the limit of the screen
        var rocketPos = rescueRocket?.position
        if ((rocketPos?.x)! + (rescueRocket?.size.width)! / 2) >= self.size.width
        {
            rocketPos?.x = self.size.width - (rescueRocket?.size.width)! / 2
            rescueRocket?.position = rocketPos!
        }
        else if ((rocketPos?.x)! - (rescueRocket?.size.width)! / 2) <= 0
        {
            rocketPos?.x = (rescueRocket?.size.width)! / 2
            rescueRocket?.position = rocketPos!
        }
        
        //when the rocket has reached the lower 3rd of the decent then deploy the landing planet
        if (rescueRocket?.position.y)! <= size.height * 0.4 && rescueRocket?.ascendingDecending == RocketMode.Decending  && landingPlanetStateMachine.canEnterState(LandingPlanetDeployState.self)
        {
            landingPlanetStateMachine.enter(LandingPlanetDeployState.self)
        }
        //when ascending the rocket reached top 40% of screen deploy the drop ship
        if (rescueRocket?.position.y)! >= size.height * 0.6 && rescueRocket?.ascendingDecending == RocketMode.Ascending  && dropShipStateMachine.canEnterState(DropShip2DeployState.self)
        {
            dropShipStateMachine.enter(DropShip2DeployState.self)
        }
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        
    }
    
    //MARK: - Level setup
    fileprivate func setUpPhysics()
    {
        physicsWorld.contactDelegate = self
        physicsWorld.speed = 1
    }
    
    private func setUpPauseButton()
    {
        let hbar  = childNode(withName: "rescueRocketHealthBar") as! SKSpriteNode
        let pause = childNode(withName: "pauseButton") as! SKSpriteNode
        let posX = hbar.position.x
        let posY = hbar.position.y - (hbar.size.width / 2) - pause.size.height / 2 - 15
        pause.position = CGPoint(x: posX, y: posY)
        pauseButton = self.childNode(withName: "pauseButton") as? SKSpriteNode
        pauseButton?.texture = SKTexture(imageNamed: "pauseButton")
    }
    
    func setUpScrollBackground()
    {
        let file = Bundle.main.path(forResource: GameConfiguration.BackgroundFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let bg = contents[(missionData?["background"])!] as! [String:Any]
        let image = bg["image"] as! String
        
        scrollBackground = self.childNode(withName: "//background") as? SKSpriteNode
        scrollBackground2 = self.childNode(withName: "//background2") as? SKSpriteNode
        scrollLayer = self.childNode(withName: "scrollLayer")
        let tex = SKTexture(imageNamed: image)
        scrollBackground.size = tex.size()
        scrollBackground.texture = tex
        scrollBackground2.size = tex.size()
        scrollBackground2.texture = tex
        scrollBackground2.position = CGPoint(x: 0.0, y: scrollBackground.size.height)
        
        let sp = bg["scrollingSpeed"] as! CGFloat
        scrollSpeed = sp
        
        if let soundSwitch = UserDefaults.standard.string(forKey: "backgroundSound")
        {
            //no need to worry about an off, as gameScene has no navigation to settings
            if soundSwitch == "ON"
            {
                //setup background sound
                let filePath = Bundle.main.url(forResource: bg["bgSound"] as? String, withExtension: nil)
                let bkSound = SKAudioNode(url: filePath!)
                bkSound.name = "bgSound"
                bkSound.run(SKAction.changeVolume(to: 0.3, duration: 0))
                self.addChild(bkSound)
            }
        }
    }
    
    //scrolls the background down the screen, or up the screen
    func scrollWorld()
    {
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        for space in scrollLayer.children as! [SKSpriteNode]
        {
            let spacePosition = scrollLayer.convert(space.position, to: self)
            if spacePosition.y <= -space.size.height
            {
                let newPosition = CGPoint(x: spacePosition.x , y: space.size.height - 1.0)
                space.position = self.convert(newPosition, to: scrollLayer)
            }
        }
    }
    
    func setUpScoreBoard()
    {
        // initialise score board and add as a child of the empty node "score"
        let score = childNode(withName: "score")
        scoreBoard = ScoreKeeper.init()
        let xPos = self.size.width  * 0.1   // 10%
        let yPos = self.size.height * 0.85 // 95%
        score?.position = CGPoint(x: xPos, y: yPos)
        score?.addChild(scoreBoard!)
    }
    
    func setUpRescueRocket()
    {
        let file = Bundle.main.path(forResource: GameConfiguration.RescueRocketFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let rk = contents[(missionData?["rescueRocket"])!] as! [String:Any]
        
        let image = rk["image"] as! String
        rescueRocket = RescueRocket(image: image)
        rescueRocket?.game = self
        rescueRocket?.decentRate = rk["decentRate"] as! CGFloat
        rescueRocket?.ascentRate = rk["ascentRate"] as! CGFloat
        rescueRocket?.bosterRate = rk["bosterRate"] as! CGFloat
        rescueRocket?.imageBooster = rk["imageBooster"] as! String
        rescueRocket?.bombType = rk["bombType"] as! String
        rescueRocket?.laserType = rk["laserType"] as! String
        rescueRocket?.maxHitPoints = rk["maxHitPoints"] as! Int
        rescueRocket?.currentHitPoints = rk["maxHitPoints"] as! Int
        rescueRocket?.collisionHitDamage = rk["collisionHitDamage"] as! Int
        rescueRocket?.crashedOnPlanetExplosion = SKTexture(imageNamed: rk["crashedOnPlanetExplosion"] as! String)
        rescueRocket?.crashedInSpaceExplosion = SKTexture(imageNamed: rk["crashedInSpaceExplosion"] as! String)
        rescueRocket?.shield = rk["shield"] as! String
        rescueRocket?.collisionSound = SKAction.playSoundFileNamed(rk["collisionSound"] as! String, waitForCompletion: false)
        
        let filePath = Bundle.main.url(forResource: rk["shieldSound"] as? String, withExtension: nil)
        rescueRocket?.shieldSound = SKAudioNode(url: filePath!)
        rescueRocket?.shieldSound?.autoplayLooped = true
        rescueRocket?.shieldSound!.name = "shieldSound"
        
        rescueRocket?.deathCrashSound = SKAction.playSoundFileNamed(rk["deathCrashSound"] as! String, waitForCompletion: false)
        
        let xPos:CGFloat = size.width / 2
        let yPos:CGFloat = size.height
        rescueRocket?.position = CGPoint(x: xPos, y: yPos)
        let gw = self.size.width
        rescueRocket!.moveButtonDistance = gw * 0.0075  //percent of the screen width
        
        rescueRocketEntity = GKEntity()
        rescueRocket?.owner = rescueRocketEntity
        let geometryComponent = RocketGeometryComponent(geometryNode: rescueRocket!)
        rescueRocketEntity?.addComponent(geometryComponent)
        let playerControlComponent = RocketPlayerControlComponent()
        rescueRocketEntity?.addComponent(playerControlComponent)
        let gotHitComponent = RocketGotHitComponent()
        rescueRocketEntity?.addComponent(gotHitComponent)
        let rocketDestroyedComponent = RocketDestroyedComponent()
        rescueRocketEntity?.addComponent(rocketDestroyedComponent)
        
        //set up the health bar
        let hbar = self.childNode(withName: "rescueRocketHealthBar") as! HealthBar
        let hbarIcon = self.childNode(withName: "rescueRocketHealthBarIcon") as! SKSpriteNode
        let tex = SKTexture(imageNamed: rk["image"] as! String)
        hbarIcon.texture = tex
        hbar.updateHealthBar(hitPointsRemaining: (rescueRocket?.maxHitPoints)!, maxHitPoints: (rescueRocket?.maxHitPoints)!)
        
        //confirming the position of the hbar to cater for different screen sizes
        let hbarX = self.size.width * 0.95
        let hbarY = self.size.height * 0.85
        hbar.position = CGPoint(x: hbarX, y: hbarY)
        let hbarIconX = hbar.position.x - hbar.size.height / 2 - hbarIcon.size.height / 2   //as the spriteNode is rotated in the editor, the width and height are reversed
        let hbarIconY = hbar.position.y - hbar.size.width / 2 + hbarIcon.size.height / 2

        hbarIcon.position = CGPoint(x: hbarIconX , y: hbarIconY)
        
        entities.append(rescueRocketEntity!)
        addChild(rescueRocket!)
    }
    
    // add in the blaster button and move buttons
    func setUpButtons()
    {
        let controlButtons = self.children.filter({ $0 is MoveControlBox }) as! Array <MoveControlBox>
        for b in controlButtons
        {
            b.configureButton()
        }
    }
    
    func setUpDropShip2()
    {
        let file = Bundle.main.path(forResource: GameConfiguration.DropShipsFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let dp = contents[(missionData?["dropShip"])!] as! [String:String]
        
        let image = dp["image"]
        let ds = DropShip2(image: image!, gameScene:self)
        ds.tractorBeam = dp["tractorBeamImage"]
        dropShip2 = ds
        self.addChild(dropShip2!)
        dropShip2?.attachedRocket(rescueRocket: rescueRocket!)
        
        dropShipStateMachine = GKStateMachine(states: [
            DropShip2WaitState(game: self),
            DropShip2DeployState(game: self),
            DropShip2CaptureState(game: self),
            DropShip2ReleaseState(game: self),
            DropShip2RetractState(game: self)
            ])
    }
    
    func setUpLandingPlanet()
    {
        let file = Bundle.main.path(forResource: GameConfiguration.LandingPlanetFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let planet = contents[(missionData?["landingPlanet"])!] as! [String:String]
        
        landingPlanet = self.childNode(withName: "landingPlanetSprite") as? LandingPlanet
        landingPlanet?.configure(planet: planet)
        landingPlanet?.game = self

        landingPlanetStateMachine = GKStateMachine(states: [
            LandingPlanetWaitState(game: self),
            LandingPlanetDeployState(game: self),
            LandingPlanetLandedState(game: self),
            LandingPlanetMissedState(game: self),
            LandingPlanetRetractState(game: self)
            ])
        landingPlanetStateMachine.enter(LandingPlanetWaitState.self)
    }
    
    //stand alone aliens if collection flag = false,
    //if collection flag = true, part of a collection so dont add AlienSpriteGeometryComponent()
    func getAlienEntity(newAlien: AlienSprite, collection: Bool) -> GKEntity
    {
        let alienEntity = GKEntity()
        let spriteComponent = AlienSpriteComponent(alienNode: newAlien)
        alienEntity.addComponent(spriteComponent)
        let explodeComponent = AlienExplodeComponent()
        alienEntity.addComponent(explodeComponent)
        
        //if collection flag = true, part of a collection so dont add AlienSpriteGeometryComponent()
        if !collection
        {
            let geometryComponent = AlienSpriteGeometryComponent()
            alienEntity.addComponent(geometryComponent)
        }
        
        //add a bomb component, only if alien drops bombs
        if newAlien.bombType != "none"
        {
            let bombReleaseComponent = AlienBombReleaseComponent()
            alienEntity.addComponent(bombReleaseComponent)
        }
        newAlien.owner = alienEntity   //added to the bomb so when a hit occours, the right component can be called to process the hit
        return alienEntity
    }
    
    func getCollectionBoxEntiry(newCollection: AlienCollectionNode) -> GKEntity
    {
        let nodeEntity = GKEntity()
        let nodeComponent = AlienCollectionNodeComponent(collectionNode: newCollection)
        nodeEntity.addComponent(nodeComponent)
        
        let geometryComponent = AlienCollectionNodeGeometryComponent()
        nodeEntity.addComponent(geometryComponent)
        
        newCollection.owner = nodeEntity   //added to the bomb so when a hit occours, the right component can be called to process the hit
        return nodeEntity
    }
    
    func setupAliens(ascentDecent: RocketMode) -> Array<AlienTuple>
    {
        //at alien setup the aliend for decent and ascent are created at the start, for later effeceny in the game, ie after landing it assist with game play for the transition to be fast
        var alienArray:Array<AlienTuple> = []
        
        let file = Bundle.main.path(forResource: GameConfiguration.AliensPackageFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let alienPackage = contents[(missionData?["alienPackage"])!] as! [Dictionary<String, Any>]
        
        let alienFile = Bundle.main.path(forResource: GameConfiguration.AliensFile, ofType: nil)
        let alienContents = NSDictionary(contentsOfFile: alienFile!) as! [String:Any]
        
        //scroll the alien package and setup all the aliens
        for alien in alienPackage
        {
            let alienType = alien["alienType"] as! String
            let alienProfile = alienContents[alienType] as! [String:Any]
  
            let behaviour: Int32 = alien["behaviour"] as! Int32
           
            if (behaviour & AlienBehaviour.PattenBox).boolValue || (behaviour & AlienBehaviour.PattenDiamond).boolValue
            {
                let alienBox = AlienCollectionNode(patten: alien["behaviour"] as! Int32, size: CGSize(width: Constants.BoxCollectionHW, height: Constants.BoxCollectionHW), game: self, ascentDecent: ascentDecent)
                
                var i = 0
                for pt in alienBox.alienLoadingPoints
                {
                    let newAlien = AlienSprite(image: alienProfile["image"] as! String, game: self, alienDict: alienProfile)
                    newAlien.position = pt
                    newAlien.name = "\(alienType)-\(i)-\(ascentDecent)"
                    
                    // if the patten is a dimond then roate aliens by - 45deg
                    if (behaviour & AlienBehaviour.PattenDiamond).boolValue
                    {
                        newAlien.run(SKAction.rotate(byAngle: .pi / -4, duration: 0.0))
                    }
                    
                    // if the collection is rotating then the aliens need to counter rotate to stay pointing down
                    if (behaviour & AlienBehaviour.Rotate).boolValue
                    {
                        let r = SKAction.repeatForever(SKAction.rotate(byAngle: .pi / -2, duration: 4.0))
                        newAlien.moveOn = r
                    }
                    
                    let alienEntity = getAlienEntity(newAlien: newAlien, collection: true)
                    alienBox.entityList.append(alienEntity)
                    alienBox.addChild(newAlien)
                    i += 1
                }
                // if the patten is a dimond then roate aliens by - 45deg
                if (behaviour & AlienBehaviour.PattenDiamond).boolValue
                {
                    alienBox.run(SKAction.rotate(byAngle: .pi / 4, duration: 0.0))
                }
                let collectionEntity = getCollectionBoxEntiry(newCollection: alienBox)
                let at = (alien: alienBox as Any, ent: collectionEntity)
                alienArray.append(at)
                continue
            }
            
            if (behaviour & AlienBehaviour.PattenTriangle).boolValue
            {
                let alienBox = AlienCollectionNode(patten: alien["behaviour"] as! Int32, size: CGSize(width: Constants.BoxCollectionHW, height: Constants.BoxCollectionHW), game: self, ascentDecent: ascentDecent)
                var i = 0
                for pt in alienBox.alienLoadingPoints
                {
                    let newAlien = AlienSprite(image: alienProfile["image"] as! String, game: self, alienDict: alienProfile)
                    newAlien.position = pt
                    newAlien.name = "\(alienType)-\(i)-\(ascentDecent)"
                    if (behaviour & AlienBehaviour.Rotate).boolValue
                    {
                        let r = SKAction.repeatForever(SKAction.rotate(byAngle: .pi / -2, duration: 4.0))
                        newAlien.moveOn = r
                    }
                    let alienEntity = getAlienEntity(newAlien: newAlien, collection: true)
                    alienBox.entityList.append(alienEntity)
                    alienBox.addChild(newAlien)
                    i += 1
                }
                let collectionEntity = getCollectionBoxEntiry(newCollection: alienBox)
                let at = (alien: alienBox as Any, ent: collectionEntity)
                alienArray.append(at)
                continue
            }
            if (behaviour & AlienBehaviour.PattenLine).boolValue
            {
                let t = SKTexture(imageNamed: alienProfile["image"] as! String) // when using Line patten size in AlienCollectionNode size is used as the size of the alien.
                let alienBox = AlienCollectionNode(patten: alien["behaviour"] as! Int32, size: t.size(), game: self, ascentDecent: ascentDecent)
                var i = 0
                for pt in alienBox.alienLoadingPoints
                {
                    let newAlien = AlienSprite(image: alienProfile["image"] as! String, game: self, alienDict: alienProfile)
                    newAlien.position = pt
                    newAlien.name = "\(alienType)-\(i)-\(ascentDecent)"
                    
                    let alienEntity = getAlienEntity(newAlien: newAlien, collection: true)
                    alienBox.entityList.append(alienEntity)
                    alienBox.addChild(newAlien)
                    i += 1
                }
                let collectionEntity = getCollectionBoxEntiry(newCollection: alienBox)
                let at = (alien: alienBox as Any, ent: collectionEntity)
                alienArray.append(at)
                continue
            }
            if (behaviour & AlienBehaviour.Circle).boolValue
            {
                let numberAliens = alien["number"] as! Int
                for i in 0..<numberAliens
                {
                    let newAlien = AlienSprite(image: alienProfile["image"] as! String, game: self, alienDict: alienProfile)
                    newAlien.position = newAlien.getOnScreenPtCircle(ascendingDecending: ascentDecent)
                    newAlien.behaviour = AlienBehaviour.Circle
                    newAlien.name = "\(alienType)-\(i)-\(ascentDecent)"   //name of the alien is the type with i counter added at the en
                    newAlien.alpha = 0.0
                    
                    let circleAction = newAlien.generateCircleAction()
                    newAlien.moveOn = SKAction.sequence([SKAction.fadeIn(withDuration: 0.25), circleAction])
                    
                    let alienEntity = getAlienEntity(newAlien: newAlien, collection: false)
                    let at = (alien: newAlien as Any, ent: alienEntity)
                    alienArray.append(at)
                }
                continue
            }
            if (behaviour & AlienBehaviour.Straight).boolValue || (behaviour & AlienBehaviour.Incline).boolValue || (behaviour & AlienBehaviour.Still).boolValue
            {
                let numberAliens = alien["number"] as! Int
                for i in 0..<numberAliens
                {
                    let newAlien = AlienSprite(image: alienProfile["image"] as! String, game: self, alienDict: alienProfile)
                    newAlien.position = newAlien.getOnScreenPtCircle(ascendingDecending: ascentDecent)
                    newAlien.behaviour = alien["behaviour"] as! Int32
                    newAlien.name = "\(alienType)-\(i)-\(ascentDecent)"   //name of the alien is the type with i counter added at the en
                    newAlien.alpha = 0.0
                    newAlien.moveOn = SKAction.fadeIn(withDuration: 0.25)
                    if !(behaviour & AlienBehaviour.Still).boolValue
                    {
                        newAlien.physicsBody?.velocity = CGVector(dx: 100, dy: 0)
                    }
                    let alienEntity = getAlienEntity(newAlien: newAlien, collection: false)
                    let at = (alien: newAlien as Any, ent: alienEntity)
                    alienArray.append(at)
                }
                continue
            }
        }
        return alienArray
    }
    
    func startAliens(aliens :Array<AlienTuple>)  //load them into the gameScene
    {
        for (alien,ent) in aliens
        {
            entities.append(ent)
            if alien is AlienSprite
            {
                let a = alien as! AlienSprite
                self.addChild(a)
                a.run(a.moveOn!)
            }
            else if alien is AlienCollectionNode
            {
                let collection = alien as! AlienCollectionNode
                entities.append(contentsOf: collection.entityList)
                self.addChild(collection)
                collection.pinAliens()  // pin the aliens in place so they move with the collection box
                
                for a in collection.children  //start the aliens rotating, if no rotation then moveOn will be nil.
                {
                    let aa = a as! AlienSprite
                    if let action = aa.moveOn
                    {
                        aa.run(action)
                    }
                }
                collection.run(collection.moveOn!)
            }
        }
    }
    
    func setUpPrizes()
    {
        let file = Bundle.main.path(forResource: GameConfiguration.PrizesPackageFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
//        let prizePackage = contents[(missionData?["prizesPackage"])!] as! Array<String>
        guard let prizePackage = contents[(missionData?["prizesPackage"])!] else
        {
            return
        }
        let prizeFile = Bundle.main.path(forResource: GameConfiguration.PrizesFile, ofType: nil)
        let prizeContents = NSDictionary(contentsOfFile: prizeFile!) as! [String:Any]
        
        for prize in prizePackage  as! Array<String>
        {
            let p = prizeContents[prize] as! Dictionary<String,Any>
            var path = PrizeTypePath.Hold  //initilisers
            var type = PrizeType.Health // initialiser
            var randY:Int = 0 // initialiser
            var randX:Int = 0 // initialiser
            
            var prizeAmount:Int = 0
            switch prize
            {
            case "Shield":
                type = PrizeType.Shield
                prizeAmount = p["prizeAmount"] as! Int
            case "Health":
                type = PrizeType.Health
                prizeAmount = p["prizeAmount"] as! Int
  //              print("Health")
            
            case "DoubleCannons":
                type = PrizeType.DoubleCannons
                prizeAmount = p["prizeAmount"] as! Int
 //               print("DoubleCannon")
                
            case "BigBomb":
                type = PrizeType.BigBomb
                prizeAmount = p["prizeAmount"] as! Int
            
            default:
                ()
            }
            switch p["path"] as! String
            {
            case "glide":
                path = PrizeTypePath.Glide
                let leftORRight = GKRandomDistribution(lowestValue: 0, highestValue: 100).nextBool()  //decide if glide starts on the left or right side of the screen
                if leftORRight == false
                {
                    randX = 0 //left
                }
                else
                {
                    randX = Int(self.size.width)
                }
                randY = GKRandomDistribution(lowestValue: Int(self.size.height * 0.45), highestValue: Int(self.size.height * 0.8)).nextInt()
            
            case "hold":
                path = PrizeTypePath.Hold
                randY = GKRandomDistribution(lowestValue: Int(self.size.height * 0.45), highestValue: Int(self.size.height * 0.8)).nextInt()
                randX = GKRandomDistribution(lowestValue: Int(self.size.width * 0.1)  , highestValue: Int(self.size.width * 0.9)).nextInt()
            
            case "bounce":
                path = PrizeTypePath.Bounce
                randY = Int(self.size.height)
                randX = Int(self.size.width * 0.1)
            default:
                ()
            }
            
            let prizeSprite = PrizeSprite(typeOfPrize: type, path: path, prizeAmount: prizeAmount, image: p["image"] as! String)
            
            if p["collectionSound"] as! String == "none"
            {
                prizeSprite.collectionSound = nil
            }
            else
            {
                prizeSprite.collectionSound = SKAction.playSoundFileNamed(p["collectionSound"] as! String, waitForCompletion: false)
            }
            prizeSprite.game = self
            prizeSprite.position = CGPoint(x: randX, y: randY)
            
            let prizeEntity = GKEntity()
            prizeSprite.owner = prizeEntity
            let spriteComponent = PrizeSpriteComponent(prizeNode: prizeSprite)
            prizeEntity.addComponent(spriteComponent)
            let geometryComponent = PrizeSpriteGeometryComponent()
            prizeEntity.addComponent(geometryComponent)
            let collectedComponent = PrizeSpriteCollectedComponent()
            prizeEntity.addComponent(collectedComponent)
            entities.append(prizeEntity)
        }
    }

    deinit 
    {
 //       NSLog("deinit() GameScene")
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
  
    //MARK: Physics world contact handlers
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // test if rocket landed on the landingPad or ground.
        if (bodyA.node?.name == "rescueRocket" || bodyB.node?.name == "rescueRocket")
        {
            if (bodyA.node?.name == "crashLine" || bodyB.node?.name == "crashLine")   //crashed in the planet, end the game
            {
                missionStatus = MissionStatus.LostCrashedPlanet
                return
            }
            if bodyB.node?.name == "landingPadSprite" || bodyA.node?.name == "landingPadSprite"
            {
                // rocket landed, changed rocket
                if (rescueRocket?.ascendingDecending == RocketMode.Landed) { return }
                rescueRocket?.ascendingDecending = RocketMode.Landed   //stop decending in the update cycle
  //              print("rocket landded")
                
                // award the loot and people rescued to the rocket.
                rescueRocket?.lootRecovered = Int((missionData?["loot"])!)!
                rescueRocket?.peopleRescued = Int((missionData?["tobeRescued"])!)!
                scoreBoard?.lootScore       = Int((missionData?["loot"])!)!
                scoreBoard?.numberRescued   = Int((missionData?["tobeRescued"])!)!
                
                landingPlanetStateMachine.enter(LandingPlanetLandedState.self)
                                
                //remove the remaining aliens, new ones will be added for the ascent.
                let alienList = self.children.filter {($0.name?.hasPrefix("Alien"))! || ($0.name?.hasPrefix("alienCollectionNode"))!}
                for node in alienList
                {
                    //to avoid the situation where the alien is being faded out and comes back through the loop and causes a crash
                    // using .hasHit as a flag for removal underway.
                    if node is AlienSprite
                    {
                        if (node as!AlienSprite).hasHit == true { continue }
                        (node as!AlienSprite).hasHit = true
                        guard let idx = entities.firstIndex(of: (node as! AlienSprite).owner!) else { continue }
                        entities.remove(at: idx)
                        let action = SKAction.fadeOut(withDuration: 0.25)
                        node.run(action, completion:
                            {
                                node.removeFromParent()
                        })
                    }
                    else if node is AlienCollectionNode
                    {
                        for alien in node.children
                        {
                            if (alien as!AlienSprite).hasHit == true { continue }
                            (alien as!AlienSprite).hasHit = true
                            guard let idx = entities.firstIndex(of: (alien as! AlienSprite).owner!) else { continue }
                            entities.remove(at: idx)
                            let action = SKAction.fadeOut(withDuration: 0.25)
                            alien.run(action, completion:
                                {
                                    alien.removeFromParent()
                            })
                        }
                        let action = SKAction.wait(forDuration: 0.25)
                        node.run(action) {
                            node.removeFromParent()
                        }
                    }
                }
                rescueRocket?.lockInPosition(true)
                self.hideShowControlButtons(hide: true)
                landingPlanet!.runRescue()
                
            }
            else if bodyB.node?.name?.prefix(5) == "Alien" || bodyA.node?.name?.prefix(5) == "Alien"
            {
                let posA = bodyA.node?.position
                let posB = bodyB.node?.position
                var vx:CGFloat = 0
                var vy:CGFloat = 0
           
                if contact.contactPoint.x < (posA?.x)!
                {
                    vx = 5
                }
                else if contact.contactPoint.x > (posA?.x)!
                {
                    vx = -5
                }
                if contact.contactPoint.y < (posA?.y)!
                {
                    vy = 5
                }
                else if contact.contactPoint.y > (posA?.y)!
                {
                    vy = -5
                }
                bodyA.applyImpulse(CGVector(dx: vx, dy: vy), at: contact.contactPoint)
                
                if contact.contactPoint.x < (posB?.x)!
                {
                    vx = 5
                }
                else if contact.contactPoint.x > (posB?.x)!
                {
                    vx = -5
                }
                if contact.contactPoint.y < (posB?.y)!
                {
                    vy = 5
                }
                else if contact.contactPoint.y > (posB?.y)!
                {
                    vy = -5
                }
                bodyB.applyImpulse(CGVector(dx: vx, dy: vy), at: contact.contactPoint)
                
                if bodyA.node?.name == "rescueRocket"
                {
                    let a = bodyA.node as! RescueRocket
                    let b = bodyB.node as! AlienSprite
                    
                    a.owner?.component(ofType: RocketGotHitComponent.self)?.gotHit(damagePoints: b.collisionDamagePoints, playCollision: true) // rescue rocket hit
                    if !b.hasHit { b.owner!.component(ofType: AlienExplodeComponent.self)?.alienHit(damagePts: a.collisionHitDamage) }   // alien hit
                }
                else
                {
                    let a = bodyA.node as! AlienSprite
                    let b = bodyB.node as! RescueRocket
                    
                    b.owner?.component(ofType: RocketGotHitComponent.self)?.gotHit(damagePoints: a.collisionDamagePoints, playCollision: true)  // rescue rocket hit
                    if !a.hasHit { a.owner!.component(ofType: AlienExplodeComponent.self)?.alienHit(damagePts: b.collisionHitDamage) } // alien hit
                }
//                print("alien strike")
            }
                
            // below else if cand be deleted
            else if bodyB.node?.name == "landingPlanetSprite" || bodyA.node?.name == "landingPlanetSprite"
            {
//                print("rocket crashed")
                rescueRocket?.ascendingDecending = RocketMode.Crashed
                landingPlanetStateMachine.enter(LandingPlanetMissedState.self)
            }
            else if (bodyB.node?.name == "TractorBeamShapeNode" || bodyA.node?.name == "TractorBeamShapeNode") && rescueRocket?.ascendingDecending != RocketMode.Docked
            {
                if (bodyA.node?.name == "TractorBeamShapeNode") // bodyB is then rescueRocket
                {
                    dropShip2?.applyTractorBeam(rescueRocket: bodyB.node as! RescueRocket, tractorBeam: bodyA.node?.parent as! SKSpriteNode, dropShipStateMachine: dropShipStateMachine)
                }
                else
                {
                    dropShip2?.applyTractorBeam(rescueRocket: bodyA.node as! RescueRocket, tractorBeam: bodyB.node?.parent as! SKSpriteNode, dropShipStateMachine: dropShipStateMachine)
                }
                rescueRocket?.ascendingDecending = RocketMode.Docked
            }
            else if bodyB.node?.name?.hasPrefix("Prize") ?? false || bodyA.node?.name?.hasPrefix("Prize") ?? false
            {
//               print("prize hit")
                if (bodyB.node!.name?.hasPrefix("Prize"))!
                {
                    let b = bodyB.node as! PrizeSprite
                    if !b.hasHit { b.owner!.component(ofType: PrizeSpriteCollectedComponent.self)?.collected() }
                }
                else
                {
                    let a = bodyA.node as! PrizeSprite
                    if !a.hasHit { a.owner!.component(ofType: PrizeSpriteCollectedComponent.self)?.collected() }
                }
            }
        }
        
        if (bodyA.node?.name == "bomb" || bodyB.node?.name == "bomb" || bodyA.node?.name == "laser" || bodyB.node?.name == "laser")  //bomb has struck something.  maybe use this same code for Lasers.
        {
            if bodyA.node?.name == "crashLine"  //bomb has hit the landing planet crash line
            {
                let b = bodyB.node as! BombSprite
                if !b.hasHit { b.owner!.component(ofType: BombExplodeComponent.self)?.bombHit(rescueRocketHit: false) } //only process if the bomb has not hit
            }
            else if bodyB.node?.name == "crashLine"
            {
                let a = bodyA.node as! BombSprite
                if !a.hasHit { a.owner!.component(ofType: BombExplodeComponent.self)?.bombHit(rescueRocketHit: false) }
            }
            else if (bodyA.node?.isKind(of: AlienSprite.self))!
            {
                let b = bodyB.node as! BombSprite
                if !b.hasHit { b.owner!.component(ofType: BombExplodeComponent.self)?.bombRemove() }
                
                let a = bodyA.node as! AlienSprite
                if !a.hasHit {a.owner!.component(ofType: AlienExplodeComponent.self)?.alienHit(damagePts: b.damagePoints ?? 10) }
            }
            else if (bodyB.node?.isKind(of: AlienSprite.self))!
            {
                let a = bodyA.node as! BombSprite
                if !a.hasHit { a.owner!.component(ofType: BombExplodeComponent.self)?.bombRemove() }
                
                let b = bodyB.node as! AlienSprite
                if !b.hasHit {b.owner!.component(ofType: AlienExplodeComponent.self)?.alienHit(damagePts: a.damagePoints ?? 10) }
            }
            else if bodyA.node?.name == "rescueRocket"
            {
                let a = bodyA.node as! RescueRocket
                let b = bodyB.node as! BombSprite
                if !b.hasHit
                {
                    b.owner!.component(ofType: BombExplodeComponent.self)?.bombHit(rescueRocketHit: true)
                    a.owner?.component(ofType: RocketGotHitComponent.self)?.gotHit(damagePoints: b.damagePoints!, playCollision: false)
                }
            }
            else if bodyB.node?.name == "rescueRocket"
            {
                let b = bodyB.node as! RescueRocket
                let a = bodyA.node as! BombSprite
                if !a.hasHit
                {
                    a.owner!.component(ofType: BombExplodeComponent.self)?.bombHit(rescueRocketHit: true)
                    b.owner?.component(ofType: RocketGotHitComponent.self)?.gotHit(damagePoints: a.damagePoints!, playCollision: false)
                }
            }
            //  friendly bomb and alien bomb collision, cancels each other out.
            else if (bodyA.node?.name == "bomb" && bodyB.node?.name == "laser") || (bodyA.node?.name == "laser" && bodyB.node?.name == "bomb")
            {
   //             print("bomb on laser strike")
                let a = bodyA.node as! BombSprite
                let b = bodyB.node as! BombSprite
                
                if !b.hasHit { b.owner!.component(ofType: BombExplodeComponent.self)?.bombRemove() }
                if !a.hasHit { a.owner!.component(ofType: BombExplodeComponent.self)?.bombRemovalWithExplosion() }
            }
        }
        if bodyA.node?.name == "shield"
        {
    //        print("shield strike")
            if (bodyB.node?.isKind(of: AlienSprite.self))!
            {
                let b = bodyB.node as! AlienSprite
                if !b.hasHit {b.owner!.component(ofType: AlienExplodeComponent.self)?.alienHit(damagePts: 100) } // apply a maximum of damage as shield destroys all
            }
            else if bodyB.node?.name == "bomb"
            {
                let b = bodyB.node as! BombSprite
                if !b.hasHit { b.owner!.component(ofType: BombExplodeComponent.self)?.bombRemovalWithExplosion() }
            }
        }
        else if bodyB.node?.name == "shield"
        {
 //           print("shield strike")
            if (bodyA.node?.isKind(of: AlienSprite.self))!
            {
                let a = bodyA.node as! AlienSprite
                if !a.hasHit {a.owner!.component(ofType: AlienExplodeComponent.self)?.alienHit(damagePts: 100) } // apply a maximum of damage as shield destroys all
            }
            else if bodyA.node?.name == "bomb"
            {
                let a = bodyA.node as! BombSprite
                if !a.hasHit { a.owner!.component(ofType: BombExplodeComponent.self)?.bombRemovalWithExplosion() }
            }
        }
        if (bodyA.node?.name == "bounceLine" && (bodyB.node?.name?.hasPrefix("Prize-"))!)  || (bodyB.node?.name == "bounceLine" && (bodyA.node?.name?.hasPrefix("Prize-"))!)
        {
            let action = SKAction.playSoundFileNamed("boing.wav", waitForCompletion: false)
            self.run(action)
        }
    }
    
    private func isUp(location:CGPoint, box:CGSize) -> Bool
    {
        if location.y > box.height * 0.6  {return true}
        return false
    }
    private func isDown(location:CGPoint, box:CGSize) -> Bool
    {
        if location.y < box.height * 0.4 {return true}
        return false
    }
    private func isLeft(location:CGPoint, box:CGSize) -> Bool
    {
        if location.x < box.width * 0.4 {return true}
        return false
    }
    private func isRight(location:CGPoint, box:CGSize) -> Bool
    {
        if location.x > box.width * 0.6 {return true}
        return false
    }
    private func isCentered(location:CGPoint, box:CGSize) -> Bool
    {
        let y = location.y
        let x = location.x
        
        // determine if the location is in the centre 3rd of the box
        if y >= box.height * 0.4 && y <= box.height * 0.6 && x >= box.width * 0.4 && x <= box.width * 0.6
        {
            return true
        }
        return false
    }
    
    func touchDown(atPoint pos : CGPoint) {
        //if a begin occours in theh move button, the store the position, as when move occours the position is used to calculate the direction.
 
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        // if moved, then move rocket and update position to the position in the touch
        let nodeList = nodes(at: pos)
        
        let shortList = nodeList.filter { (node) -> Bool in
            if node is MoveControlBox { return true }
            return false
        }
        
        for n in shortList
        {
            switch n.name
            {
            case "leftTopControl":
                moveButtonDirectionMask = MoveButtonDirection.Left | MoveButtonDirection.Up
 //               print("leftTop")
            case "leftCentreControl":
                moveButtonDirectionMask = MoveButtonDirection.Left
//                print("leftCentre")
            case "leftBottomControl":
                moveButtonDirectionMask = MoveButtonDirection.Left | MoveButtonDirection.Down
//                print("leftBottom")
            case "centreTopControl":
                moveButtonDirectionMask = MoveButtonDirection.Up
//                print("centreTop")
            case "centreCentreControl":
                moveButtonDirectionMask = MoveButtonDirection.None
//                print("centreCentre")
            case "centreBottomControl":
                moveButtonDirectionMask = MoveButtonDirection.Down
//                print("centreBottom")
            case "rightTopControl":
                moveButtonDirectionMask = MoveButtonDirection.Right | MoveButtonDirection.Up
//                print("rightTop")
            case "rightCentreControl":
                moveButtonDirectionMask = MoveButtonDirection.Right
//                print("rightCentre")
            case "rightBottomControl":
                moveButtonDirectionMask = MoveButtonDirection.Right | MoveButtonDirection.Down
//                print("rightBottom")
                
            default:
                ()
            }
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        print("touchUp = \(pos)")
        
        // if the mission has ended and a touch, dismiss the summary banner and back to the start scene
        if missionEnded
        {
            guard let newScene = StartScene(fileNamed: "StartScene") else
            {
                fatalError("Can not load Game Scene")
            }
            guard let refNode = self.childNode(withName: "MissionSummaryBanner") as? MissionResultsSummary else
            {
                return
            }
            
            refNode.closeScore = true //advise the timers to close down.
            newScene.parentVC = self.parentVC
            newScene.size = CGSize(width: sceneWidth, height: sceneHeight)  //adjusted for screen size
            newScene.scaleMode = .aspectFill
            
            let w = UIApplication.shared.keyWindow
            //SKScene is 1.81 times larger than the ViewCOntroller as such a calculation between the two is necessary to make banners, safe area and SKScene
            let topPadding = ((w?.safeAreaInsets.top)! + kGADAdSizeBanner.size.height) * 1.81  //safe area plus the height of the Google add
            let sceneFrame = scene?.frame
            let rect = CGRect(x: (scene?.frame.origin.x)! , y: (scene?.frame.origin.y)!, width: (sceneFrame?.size.width)!, height: (sceneFrame?.size.height)! - topPadding)
            
            newScene.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
            let transition = SKTransition.doorway(withDuration: TimeInterval(0.5))
            self.view?.presentScene(newScene, transition: transition)
            return
        }
        
        let nodeList = nodes(at: pos)
       // if the touch is anywhere on the screen appart from the direction control fire the blaster
        
        if nodeList.filter({ ($0.name?.hasSuffix("Control"))!}).count > 0
        {
            moveButtonDirectionMask = MoveButtonDirection.None
            return
        }
        
        //check for help screens, if present remove them
        if nodeList.contains(where: { (node) -> Bool in
            return node is HelpScreens
        })
        {
            let node = self.children.filter({ ($0.name == "helpScreen")})
            for n in node
            {
                n.removeFromParent()
            }
        }
        
        if nodeList.contains(pauseButton!)
        {
            if (pauseButton?.isPaused)!
            {
                pauseButton?.isPaused = false
                self.isPaused = false
                pauseButton?.texture = SKTexture(imageNamed: "pauseButton")
            }
            else
            {
                pauseButton?.isPaused = true
                self.isPaused = true
                pauseButton?.texture = SKTexture(imageNamed: "pauseButtonPaused")
            }
            return
        }
        
        // else the touch is to fire the laser or drop a bomb
        if rescueRocket?.ascendingDecending == RocketMode.Decending  //dropping bombs, all friendly
        {
            //place the bomb at the base and centre line of the rescue rocket
            rescueRocket?.dropBomb(game: self)
        }
        else if rescueRocket?.ascendingDecending == RocketMode.Ascending //firing lasers
        {
            //place the laser at the top and centre line of the rescue rocket
            rescueRocket?.fireLaser(game: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        //if a begin occours in theh move button, the store the position, as when move occours the position is used to calculate the direction.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for t in touches
        {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //hide or show th control buttons
    func hideShowControlButtons(hide: Bool)
    {
        let controlButton = self.children.filter({ $0 is MoveControlBox }) as! Array <MoveControlBox>
        
        for b in controlButton
        {
            b.isHidden = hide
        }
    }
    
    // MARK: notification handlers
    
    @objc func returningFromBackGround(_ sender:NSNotification)
    {
        //aplication resiginign active, pause the game
        //scene is paused and un-paused automatically by the kit,  to effect a pause on returning, have to add in a 0.4 delay in pausing on return from background
        //as kit will undo the pause as notification fires before kit unpauses
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
            self.pauseButton?.isPaused = true
            self.isPaused = true
            self.pauseButton?.texture = SKTexture(imageNamed: "pauseButtonPaused")
        }
    }
    
}
    
//reference node subclass to hold a mission summary banner
class MissionResultsSummary: SKReferenceNode
{
    var score:Int
    {
        didSet
        {
            let scoreNode = self.childNode(withName: "//scoreLabel") as? SKLabelNode
            
            var increment = 25
            if increment >= score
            {
                scoreNode?.text = "Score - " + String(score)
                return
            }
            Timer.scheduledTimer(withTimeInterval: 0.0000001, repeats: true) { (timer) in
                scoreNode?.text = "Score - " + String(increment)
                increment += 25
                if increment > self.score || self.closeScore == true
                {
                    scoreNode?.text = "Score - " + String(self.score)
                    timer.invalidate()
                }
            }
        }
    }
    var rescued:Int
    {
        didSet
        {
            let rescuedNode = self.childNode(withName: "//rescued") as? SKLabelNode
            
            var increment = 25
            if increment >= rescued
            {
                rescuedNode?.text = "Rescued - " + String(rescued)
                return
            }
            Timer.scheduledTimer(withTimeInterval: 0.0000001, repeats: true) { (timer) in
                rescuedNode?.text = "Rescued - " + String(increment)
                increment += 25
                if increment > self.rescued || self.closeScore == true
                {
                    rescuedNode?.text = "Rescued - " + String(self.rescued)
                    timer.invalidate()
                }
            }
        }
    }
    var loot:Int
    {
        didSet
        {
            let lootNode = self.childNode(withName: "//loot") as? SKLabelNode
            
            var increment = 25
            if increment >= loot
            {
                lootNode?.text = "Loot - " + String(loot)
                return
            }
            Timer.scheduledTimer(withTimeInterval: 0.0000001, repeats: true) { (timer) in
                lootNode?.text = "Loot - " + String(increment)
                increment += 25
                if increment > self.loot || self.closeScore == true
                {
                    lootNode?.text = "Loot - " + String(self.loot)
                    timer.invalidate()
                }
            }
        }
    }
    var missionName:String
    {
        didSet
        {
            let missionNameNode = self.childNode(withName: "//missionName") as? SKLabelNode
            missionNameNode?.text = "Mission - \(missionName)"
        }
    }
    var resultMessage:String
    {
        didSet
        {
            let resultMessageNode = self.childNode(withName: "//resultMessage") as? SKLabelNode
            resultMessageNode?.text = resultMessage
        }
    }
    var planetImage:String
    {
        didSet
        {
            let planetImageNode = self.childNode(withName: "//planetImage") as? SKSpriteNode
            planetImageNode?.texture = SKTexture(imageNamed: planetImage)
        }
    }
    var closeScore:Bool = false //this flag, is set true when result banner is closing,  use to adivse timers to shut down.
    
    override init(fileNamed fileName: String?) {
        self.score = 0
        self.rescued = 0
        self.loot = 0
        self.missionName = ""
        self.resultMessage = ""
        self.planetImage = ""
        
        super.init(fileNamed: fileName)
            self.zPosition = LayerLevel.Controls
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    deinit {
//        print("reference node deinit")
    }
    
}
