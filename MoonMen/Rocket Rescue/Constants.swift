//
//  Constants.swift
//  MoonMen
//
//  Created by Christopher Bunn on 30/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

struct GameConfiguration
{
    static let LandingPlanetInformationFile = "LandingPlanets.plist"
    static let StageMapFile = "StageLayout.plist"
    static let BackgroundFile = "Background.plist"
    static let DropShipsFile = "Dropships.plist"
    static let RescueRocketFile = "RescueRockets.plist"
    static let LandingPlanetFile = "LandingPlanets.plist"
    static let BombsFile = "Bombs.plist"
    static let AliensFile = "Aliens.plist"
    static let AliensPackageFile = "AlienPackages.plist"  // each level has a file that lists the aliens and number to be used in the mission
    static let PrizesPackageFile = "PrizePackages.plist"
    static let PrizesFile = "Prizes.plist"
    static let RescuePackage = "RescuePackages.plist"
}

struct PhysicsCategory
{
    static let None        :UInt32 = 0
    static let RescueRocket:UInt32 = 1
    static let DropShip    :UInt32 = 2
    static let Alien       :UInt32 = 4
    static let LandingPad  :UInt32 = 8
    static let Planet      :UInt32 = 16
    static let Prize       :UInt32 = 32
    static let TrackorBeam :UInt32 = 64
    static let FriendBombs :UInt32 = 128  //friendly
    static let AlienBombs  :UInt32 = 256  //unfriendly ie alien bombs
    static let Shield      :UInt32 = 512
    static let Collection  :UInt32 = 1024
    static let BounceLine  :UInt32 = 2048
    static let CrashLine   :UInt32 = 4096
    static let All         :UInt32 = UInt32.max
}

struct MoveButtonDirection
{
    static let None :UInt32 = 0
    static let Left :UInt32 = 1
    static let Right:UInt32 = 2
    static let Up   :UInt32 = 4
    static let Down :UInt32 = 8
}

// object layer levels for the zPosition of the various game objects
struct LayerLevel
{
    static let Background:CGFloat = 0
    static let Beam      :CGFloat = 1
    static let Planets   :CGFloat = 2
    static let Aliens    :CGFloat = 3
    static let Prizes    :CGFloat = 4
    static let BombsLasers:CGFloat = 5
    static let Rocket    :CGFloat = 6 //rescue rocket
    static let Controls  :CGFloat = 7
    static let HelpScreen :CGFloat = 8
}

//rocket direction movements as a result of play input
enum MoveRocketDirection
{
    case None, Left, Right, Up, Down
}

//is the rocket on way to moon or back to 
enum RocketMode
{
    case Ascending, Decending, Landed, Crashed, Docked
}

//define the state the mission is in, underway, lost or won
enum MissionStatus
{
    case Underway, Won, LostToSpace, LostRocketDestroyed, LostCrashedPlanet
}

//defines the type of price for the prizes
enum PrizeType:String
{
    case Health, Shield, DoubleCannons, BigBomb
    
    func stringValue() -> String
    {
        return self.rawValue
    }
}

enum PrizeTypePath
{
    case Hold, Glide, Bounce
}

// typealias AlienTuple = (alien:AlienSprite, ent:GKEntity)

//alien is type any, this allows any AlienSprite, AlienCollectionNode and other future types. If obj is Class can be used to determine what type alien is before use
typealias AlienTuple = (alien:Any, ent:GKEntity)

//alien tuple for holding aliens and their rescue animation on the landing planet
typealias RescuedAlienTuple = (alien:SKSpriteNode, animate:SKAction)

// Score boards identifiers, ID's
struct GamePlayScoreBoards
{
    static let allTimeHighest = "All_Time"
    static let allTimeLoot = "LootCaptured"
    static let allTimeRescues = "aliensRescued"
    
    static let allTimeHighestDev = "All_Time-Dev"
    static let allTimeLootDev = "LootCaptured-Dev"
    static let allTimeRescuesDev = "aliensRescued-Dev"
}


// these can be ored together for multi behaviours,  only the collection behavious can be ored with basic behavious
struct AlienBehaviour
{
    static let Still        :Int32 = 1 // "still"   basic behaviour
    static let Straight     :Int32 = 2 // "straight" basic behaviour
    static let Incline      :Int32 = 4 // "incline" basic behaviour
    static let Circle       :Int32 = 8 // "circle" basic behaviour
    static let Rotate       :Int32 = 16 // "rotate"
    static let PattenBox    :Int32 = 32 // "pattenbox" // square box
    static let PattenDiamond:Int32 = 64 // "pattenDiamond"
    static let PattenTriangle:Int32 = 128 // triangle
    static let PattenLine   :Int32 = 256  // static line of aliens
}
struct Constants
{
    static let BoxCollectionHW :CGFloat = 150.0
}
