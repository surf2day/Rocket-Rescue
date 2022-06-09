//
//  StartScene.swift
//  MoonMen
//
//  Created by Christopher Bunn on 31/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

import GoogleMobileAds

class StartScene: SKScene  {
    
    var parentVC:GameViewController?
    
    var tap = UITapGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    
    var currentStage:Int = 0
    var missionArray:[MissionReferenceNode]? = []
    
    var gameData:GameData? // players scores and progress through the game, stored on file and at game center
    
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
    
    override func sceneDidLoad()
    {
        let note = NotificationCenter.default
        note.addObserver(self, selector: #selector(playerLoggedIn(_:)), name: NSNotification.Name.GKPlayerAuthenticationDidChangeNotificationName, object: nil)
        // set up KVO on background sound, so if changed in settings it can be turned off.
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: "backgroundSound",
                                          options: [.new],
                                          context: nil)
    }
    
    override func didMove(to view: SKView)
    {
 //       NSLog("screen size = \(CGSize(width: screenWidth, height: screenHeight))")
 //       NSLog("scene size  = \(size)")
        
        //centre the new galaxies coming soon banner in the middle of the screen & hide from view
        if let newGalaxiesBanner = self.childNode(withName: "comingSoonSprite")
        {
            let xPos = self.size.width / 2.0
            let yPos = self.size.height / 2.0
            newGalaxiesBanner.position = CGPoint(x: xPos, y: yPos)
            let tex = SKTexture(imageNamed: "moreGalaxiesSoon")
            let ngb = newGalaxiesBanner as! SKSpriteNode
            ngb.texture = tex
            ngb.size = tex.size()
            newGalaxiesBanner.isHidden = true
        }
        
        self.gameData = GameDataMrg.sharedGameDataMgr.loadGameData(viewController: parentVC!)
        if self.gameData == nil
        {
            // no saved game on the device, initalise a new gameData structure and start a completely new game at stage 1 mission 1
            self.gameData = GameDataMrg.sharedGameDataMgr.createEmptyGameData()
        }
        
        let setting = self.childNode(withName: "settings") as! SKSpriteNode
        setting.texture = SKTexture(imageNamed: "settingsIcon")
        
        tap.addTarget(self, action: #selector(StartScene.launchTapped(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
        
        swipeLeft.direction = .left
        swipeLeft.addTarget(self, action: #selector(StartScene.swippedLeft(_:)))
        self.view?.addGestureRecognizer(swipeLeft)
        
        swipeRight.direction = .right
        swipeRight.addTarget(self, action: #selector(StartScene.swippedRight(_:)))
        self.view?.addGestureRecognizer(swipeRight)
        
        let _ = isSoundSwitchedOn() //let _ to supress the warning. otherwise update the function to void return value.
        
        currentStage = getCurrentStage()
        //loop backwards if there are no missions then, this stage has not been progressed and as such step back a stage
        //this is required, if a player scrolls forwrd to look at missions then a stage is created in the data but not played.
        configureMap(gameDataForConfig: gameData!, startStageNumber: currentStage)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        let reload = GameDataMrg.sharedGameDataMgr.resetReload
        if reload
        {
            GameDataMrg.sharedGameDataMgr.scoresReset()
            self.gameData = GameDataMrg.sharedGameDataMgr.loadGameData(viewController: parentVC!)
            currentStage = getCurrentStage()
            self.removeMissions()
            configureMap(gameDataForConfig: gameData!, startStageNumber: currentStage)
        }
    }
    
    //retrieve the current users achievements and then comfigure the missions.
    
    private func configureMap(gameDataForConfig:GameData, startStageNumber:Int)
    {
        var playerMission:Int = -1
        
        var previousStageComplete:Bool = true
        
        if startStageNumber > 0
        {
            let previousStageNumber = startStageNumber - 1
            let missionDataList = gameDataForConfig.stages[previousStageNumber].missions
            
            // read in the stage configuration file for this stage
            //if the number of missions in the config file and gamedata file is the same, then the stage is complete if the last mission complete = True
            let file = Bundle.main.path(forResource: GameConfiguration.StageMapFile, ofType: nil)
            let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
            let previousStageString:String = "stage" + previousStageNumber.description
            
            let dict = contents[previousStageString] as? [String:Any]
            let previousMissionList = dict!["missions"] as! Array<Dictionary<String,String>>
            
            if previousMissionList.count == missionDataList.count
            {
                if !(missionDataList.last?.completed)!
                {
                    previousStageComplete = false
                }
            }
            else
            {
                previousStageComplete = false
            }
        }
        
        // the top safe area is needed for iphone X and alike which has a section covering the screen
        let w = UIApplication.shared.keyWindow
        let padding = w?.safeAreaInsets
        
        if gameDataForConfig.stages.indices.contains(startStageNumber)
        {
            let startStage = gameDataForConfig.stages[startStageNumber]
            playerMission = startStage.missions.count
            for (idx, m) in startStage.missions.enumerated()
            {
                if m.completed == true { continue }
                if m.completed == false
                {
                    playerMission = idx
                    break
                }
            }
        }
        // if the start stage number is beyond the number of stages in the saved game data then a new stage has stated and a blank (empty) stage
        // needs to be added to the data.
        else
        {
            gameDataForConfig.stages.append(GameDataMrg.sharedGameDataMgr.createStage())
            let startStage = gameDataForConfig.stages[startStageNumber]
            playerMission = startStage.missions.count
        }
        
        let startStageString:String = "stage" + startStageNumber.description
        
        let file = Bundle.main.path(forResource: GameConfiguration.StageMapFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        let dict = contents[startStageString] as? [String:Any]
        let missionList = dict!["missions"] as! Array<Dictionary<String,String>>
        
        let stageTitle = dict!["stageTitle"] as! String
        let stageTitleLabel  = self.childNode(withName: "//stageTitle") as!SKLabelNode
        stageTitleLabel.text = stageTitle
        
        let setting = self.childNode(withName: "settings") as! SKSpriteNode
        // position the settings button
        let settingPosX = self.size.width - setting.size.width / 2.0
        let settingPosY = setting.size.height / 2.0 + (padding?.bottom)!
        setting.position = CGPoint(x: settingPosX, y: settingPosY)
        
        let yGap = (CGFloat(self.size.height) - setting.size.height - (padding?.bottom)!) / CGFloat(missionList.count) //gaps between planets
        
        var startY = (self.size.height - (padding?.top)! - kGADAdSizeBanner.size.height) - yGap / 2   //start within the safearea and space for the add, ie add height
        
        let rand = GKRandomDistribution(lowestValue: 0, highestValue: Int(self.size.width))
        var idx:Int = 0
        
        //lay out the missions for the player.
        for mission in missionList
        {
            let refNode = MissionReferenceNode(fileNamed: "MissionScene")
            refNode.missionNumber = idx
            refNode.stageNumberString = startStageString
            refNode.stageNumber = startStageNumber
            refNode.name = "mission"

            //generate a random x position
            let xPos = rand.nextInt()
            refNode.position = CGPoint(x: CGFloat(xPos), y: startY)
            
            let planetLabel  = refNode.childNode(withName: "//planetLabel") as! SKLabelNode
            let planetSprite = refNode.childNode(withName: "//planetSprite") as! SKSpriteNode
            let missionLabel = refNode.childNode(withName: "//missionLabel") as! SKLabelNode
            let launchButton = refNode.childNode(withName: "//launchButton") as! SKSpriteNode

            if idx > playerMission || previousStageComplete == false
            {
                launchButton.removeFromParent()
            }
            planetLabel.text = mission["name"]
            let tex = SKTexture(imageNamed: mission["image"]!)
            planetSprite.texture = tex
            missionLabel.text = mission["title"]

            missionArray?.append(refNode)
            self.addChild(refNode)
            startY -= yGap
            idx += 1
        }
        //scale up the next mission for the player to achieve and display the launch button
        // only scale up if there is a mission to be played.  ie if player has swipped to future stages, then dont focus a stage
        if playerMission >= 0 && playerMission < (missionArray?.count)! && previousStageComplete
        {
            let activeMission = missionArray![playerMission]
            let action = SKAction.scale(by: 2.0, duration: 0.25)
            activeMission.run(action) {
                self.drawMissionPath()
            }
        }
        else
        {
            self.drawMissionPath()
        }
    }
    
    func drawMissionPath()
    {
        // join all the nodes with a path (line) to show the way forward.
        
        var points:[CGPoint] = []
        for m in missionArray!
        {
            points.append(m.position)
        }
        let missionPath = SKShapeNode(splinePoints: &points, count: points.count)
        missionPath.lineWidth = 20
        let tex = SKTexture(imageNamed: "star")
        missionPath.strokeTexture = tex
        missionPath.name = "missionPath"
        self.addChild(missionPath)
    }
    
    private func removeMissions()
    {
        let missionNodes = self.children.filter( {$0.name == "mission"} )
        for m in missionNodes
        {
            m.removeFromParent()
        }
        let missionPaths = self.children.filter( {$0.name == "missionPath"} )
        for mp in missionPaths
        {
            mp.removeFromParent()
        }
        missionArray?.removeAll()
    }
    
    // MARK: tap guesture recogniser handlers
    
    @objc func swippedLeft(_ sender:UISwipeGestureRecognizer)
    {
        let file = Bundle.main.path(forResource: GameConfiguration.StageMapFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
        if currentStage + 1 >= contents.count
        {
             // no more stages to display, display more galavies coming soon banner
            if let newGalaxiesBanner = self.childNode(withName: "comingSoonSprite"), let stageTitle = self.childNode(withName: "stageTitle")
            {
                //if newHalaxies Banner is already showing, dont show it again, just return
                if !newGalaxiesBanner.isHidden { return }
                self.removeMissions()
                newGalaxiesBanner.isHidden = false
                stageTitle.isHidden = true
                currentStage += 1
            }
            return
        }
        currentStage += 1
        self.removeMissions()
        self.configureMap(gameDataForConfig: gameData!, startStageNumber: currentStage)
        
//         print("swipped left")
    }
    
    @objc func swippedRight(_ sender:UISwipeGestureRecognizer)
    {
        if currentStage - 1 < 0
        {
            return
        }
        if let newGalaxiesBanner = self.childNode(withName: "comingSoonSprite"), let stageTitle = self.childNode(withName: "stageTitle")
        {
            newGalaxiesBanner.isHidden = true
            stageTitle.isHidden = false
        }
        currentStage -= 1
        self.removeMissions()
        self.configureMap(gameDataForConfig: gameData!, startStageNumber: currentStage)
        
//       print("swipped right")
    }
    
    @objc func launchTapped(_ sender:UITapGestureRecognizer)
    {
        if sender.state != .ended {return}
        
        let tapLocation:CGPoint = sender.location(in: sender.view)
        let sceneLocation = convertPoint(fromView: tapLocation)
        let nodeList = nodes(at: sceneLocation)
        
        //first test if the settings button has been tapped as any tap will kick out on the lauch button test, if there is no launch button
        let settingsButt = nodeList.filter({$0.name == "settings"})
        if settingsButt.count > 0
        {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
            vc.gameData = gameData
            vc.parentVC = self.parentVC
            self.view?.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
        
        //this is not a prefered approach, however while the launchbutton is removed for missions not achieved, it remain in place inside the reference node.
        // prefernce would be to have the isHidden property take care of the display and test if it should be tapped.
        let launchButt = nodeList.filter({$0.name == "launchButton"})
        if launchButt.count == 0
        {
            return
        }
        
        if let refNode = nodeList.first(where: { $0 .isKind(of: MissionReferenceNode.self) }) as! MissionReferenceNode?
        {
            let file = Bundle.main.path(forResource: GameConfiguration.StageMapFile, ofType: nil)
            let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]
            let dict = contents[refNode.stageNumberString!] as? [String:Any]
            let missionList = dict!["missions"] as! Array<Dictionary<String,String>> //the Stage will be selected based on the point in the game player has achieved
            let mission = missionList[refNode.missionNumber]          // this is also selected based on the point in the game the player has achieved
            
            guard let newScene = GameScene(fileNamed: "GameScene") else
            {
                fatalError("Can not load Game Scene")
            }
            newScene.parentVC = self.parentVC
            newScene.size = CGSize(width: sceneWidth, height: sceneHeight)  //adjusted for screen size
            newScene.scaleMode = .aspectFill
            newScene.missionData = mission
            newScene.gameData = gameData
            newScene.missionNumber = refNode.missionNumber
            newScene.stageNumber = refNode.stageNumber
            
            let bc = self.childNode(withName: "backgroundSound")
            bc?.run(SKAction.stop())
            bc?.removeFromParent()
            
            //sound for the launch tap
            let launchSound = SKAction.playSoundFileNamed("launchButtonBeep.wav", waitForCompletion: false)
            self.run(launchSound)
            
            let transition = SKTransition.fade(withDuration: TimeInterval(1.5))
            view?.presentScene(newScene, transition: transition)
        }
    }
    
    // MARK: call back notification handler for when a user signs into game centre .
    @objc func playerLoggedIn(_ sender:NSNotification)
    {
        // once a player has logged in, we can retrieve their saved game data and update the progress
        // player needs to be signed into iCloud to utilise save and retrieve games,  if player is not login to icloud or indeed game centre game data is daved locally.
        
        let player = sender.object as! GKLocalPlayer
        if !player.isAuthenticated { return }
        
        // if player is underage, set advertising flag appropiatly according to GDPR EEA privacy rules
        if player.isUnderage
        {
            parentVC?.setEEAUnderageFlag()
        }
        
        player.fetchSavedGames { (savedGames, error) in
            if error == nil
            {
                guard let gameCnt = savedGames?.count else { return }
                if gameCnt <= 0 { return }
                
                // there is saved games, iterate through, process and reload StartScene
//                print("there are game(s) on game center")
                
                let group = DispatchGroup()
                var decodedSavedGames: Array<GameData> = []
                for save in savedGames!
                {
                    group.enter()
                    save.loadData(completionHandler: { (data, error) in
                        if let gameCenterData = try? JSONDecoder().decode(GameData.self, from:data!)
                        {
                            decodedSavedGames.append(gameCenterData)
                        }
                        group.leave()
                    })
                }
                
                group.notify(queue: .main)
                {
                    var mostCurrentGameIndx = 0
                    var mostCurrentGameMissionCount = 0
                    
                    var i = 0
                    for game in decodedSavedGames
                    {
                        let missionCount = self.countMissions(game: game)
                        if missionCount > mostCurrentGameMissionCount
                        {
                            mostCurrentGameMissionCount = missionCount
                            mostCurrentGameIndx = i
                        }
                        i += 1
                    }
                    
                    // resolve conflicts
                    let gameCentreMaster = decodedSavedGames[mostCurrentGameIndx]
                    var deleteGames = savedGames
                    deleteGames?.remove(at: mostCurrentGameIndx)
                    //delete all the old games.
                    for d in deleteGames!
                    {
                        player.deleteSavedGames(withName: d.name! , completionHandler: { (error) in
                            print("game deleted name: \(String(describing: d.name))")
                        })
                    }

                 /*   savedGames?[mostCurrentGameIndx].loadData(completionHandler: { (data, error) in
                        if error == nil
                        {
                            player.resolveConflictingSavedGames(deleteGames!, with: data!, completionHandler: { (saved, error) in
                                if error != nil
                                {
                                    NSLog("resolve comflict failed %s", (error?.localizedDescription)!)
                                }
                            })
                        }
                    }) */
                    
                    //at this point determine the most progressed, gamecentre or game stored on the device.
                    //if gameCenter then alter player to decided if want to update to most progressed game
                    let gcmCount = self.countMissions(game: gameCentreMaster)
                    let sgCount = self.countMissions(game: self.gameData!) //locally device saved game
                    if sgCount >= gcmCount
                    {
                        return  // device saved game most progressed.
                    }
                    
                    let alert = UIAlertController(title: "Game Achievements",
                                                  message: "We have found more recent game progress, Loaded it?",
                                                  preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        self.removeMissions()
                        self.gameData = gameCentreMaster
                        self.currentStage = 0
                        self.currentStage = self.getCurrentStage()
                        self.configureMap(gameDataForConfig: gameCentreMaster, startStageNumber: self.currentStage)
                        try! GameDataMrg.sharedGameDataMgr.saveGameData(gameData: self.gameData!)
                    })
                    let actionNO = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    alert.addAction(actionOK)
                    alert.addAction(actionNO)
                    self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func countMissions(game: GameData) -> Int
    {
        var counter = 0
        
        for stage in game.stages
        {
            counter += stage.missions.count
        }
        return counter
    }
    
    //return the current stage being played. current stage if contain missions and the last mission is yes to be completed.
    //if the number of missions in the game data is the same as the stage layout and the last one is complete then the next stage has to be loaded.
    func getCurrentStage() -> Int
    {
        let file = Bundle.main.path(forResource: GameConfiguration.StageMapFile, ofType: nil)
        let contents = NSDictionary(contentsOfFile: file!) as! [String:Any]  // number of game stages on disk.
        var s = 0
        for (idx, stage) in (gameData?.stages.enumerated().reversed())!
        {
            if stage.missions.count == 0 { continue }
            let str = "stage" + idx.description
            let stageData = contents[str] as! [String:Any]
            let missionList = stageData["missions"] as! Array<Dictionary<String,String>>
            
            if stage.missions.count < missionList.count
            {
                s = idx
                return s
            }
            if stage.missions.count == missionList.count
            {
                if (stage.missions.last?.completed)! && idx + 1 < contents.count
                {
                    return idx + 1
                }
                else
                {
                    return idx
                }
            }
        }
        return s
    }
    
    deinit {
        view?.removeGestureRecognizer(tap)
        view?.removeGestureRecognizer(swipeRight)
        view?.removeGestureRecognizer(swipeLeft)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.GKPlayerAuthenticationDidChangeNotificationName, object: nil)
        self.childNode(withName: "backgroundSound")?.removeFromParent()
        UserDefaults.standard.removeObserver(self, forKeyPath: "backgroundSound", context: nil)
    }
    
    // check user defaults for sound switch, if no entry set backgroundSound on and create an entry, on which call the
    //notification handler and starts the music, this is the senario for apps first launch
    // also set up observing so when the value changes action can be taken.
    // "ON" is on and "OFF" is off
    func isSoundSwitchedOn() -> Bool
    {
        let defaults = UserDefaults.standard
        if let onOff = defaults.string(forKey: "backgroundSound")
        {
            if onOff == "ON"
            {
                let backgroundSound = SKAudioNode(fileNamed: "startSceneBackgroundSound.wav")
                backgroundSound.name = "backgroundSound"
                backgroundSound.autoplayLooped = true
                self.addChild(backgroundSound)
                return true
            }
            else
            {
                return false
            }
        }
        // if no entry in defaults, create an entry and set it on, the KVO then swithc it on. this is on app first launch.
        defaults.set("ON", forKey: "backgroundSound")
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "backgroundSound"
        {
           if let onOff = change?[NSKeyValueChangeKey.newKey]
           {
                if onOff as! String == "ON"
                {
                    //turn music on if not already on
                    let backgroundSound = SKAudioNode(fileNamed: "startSceneBackgroundSound.wav")
                    backgroundSound.name = "backgroundSound"
                    backgroundSound.autoplayLooped = true
                    backgroundSound.run(SKAction.changeVolume(to: 0.3, duration: 0))
                    self.addChild(backgroundSound)
                }
                else
                {
                    //turn off if not already off
                    let backgroundSound = self.childNode(withName: "backgroundSound") as! SKAudioNode
                    backgroundSound.run(SKAction.stop())
                    backgroundSound.removeFromParent()
                }
           }
        }
    }
}

//reference node subclass to hold a mission number
class MissionReferenceNode: SKReferenceNode
{
    var missionNumber:Int = 0
    var stageNumberString:String?
    var stageNumber:Int = 0
    
    override init(fileNamed fileName: String?) {
        super.init(fileNamed: fileName)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 150.0, height: 150.0))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit
    {
//        print("reference node deinit")
    }
    
}
