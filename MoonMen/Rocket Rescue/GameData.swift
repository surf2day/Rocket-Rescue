//
//  GameData.swift
//  Space Raider
//
//  Created by Christopher Bunn on 6/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameKit

extension String {
    
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), key, key.count, self, self.count, &digest)
        let data = Data(bytes: digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Data {
    var md5 : String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ =  self.withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(self.count), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}

let KeyChainSaveKey = "RocketRaiderHash"

class GameData: Codable {

    struct Mission: Codable {
        var bestScore:Int
        var numberRescued:Int
        var totalLoot:Int
        var completed:Bool
        
        init()
        {
            self.bestScore = 0
            self.numberRescued = 0
            self.totalLoot = 0
            self.completed = false
        }
    }
    
    struct Stage: Codable{
        var totalScore:Int  // these can be removed, missions maintain each missions total and the game totals keep score for the game.
        var totalLoot:Int
        var totalRescued:Int
        var missions:[Mission]
        
        init()
        {
            self.totalScore = 0
            self.totalLoot = 0
            self.totalRescued = 0
            
            self.missions = []
        }
    }
    
    var stages:Array<Stage>
    var lastSaveDateTime:Date
    // game wide total scores
    var gameTotalScore:Int
    var gameTotalLoot:Int
    var gameTotalRescued:Int
    
    init()
    {
        self.stages = [Stage()]
        self.lastSaveDateTime = Date(timeIntervalSince1970: 5) //set the date way back  this allows any storeed games to more recent the a blank one created now
        gameTotalScore = 0
        gameTotalLoot = 0
        gameTotalRescued = 0
    }
}

class GameDataMrg: NSObject {
    
    static let sharedGameDataMgr = GameDataMrg()
    
    var resetReload:Bool = false  // set true when player resets the game data to zero/start,  when set true StartScene reloads the map.
    
    override init() {
        super.init()
    }
    
    private let gameDataFile:String = "gameDataFile.json"
    
    private var documentFolder:URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }
    
    // a view controller is passed in here, just incase the MD5 hash does not match and the game is reset and user alerted
    func loadGameData(viewController: UIViewController) -> GameData?
    {
        let dataFileHash:String? = KeychainWrapper.standard.string(forKey: KeyChainSaveKey)
        
        let dataFileURL = documentFolder.appendingPathComponent(gameDataFile)
        if let rawData = try? Data(contentsOf: dataFileURL), let gameData = try? JSONDecoder().decode(GameData.self, from:rawData)
        {
            //calcuate hash on the file and compare with the keychain, if equal then return gameData otherwise return nil
            let validateHashString = rawData.md5
            
            if dataFileHash == validateHashString
            {
                return gameData
            }
            else
            {
                // file MD5 hash dont match, likely the file has been tampered with or corrupt, reset the game to the start.
                // notify user and remove the file and MD5 hash key
                let alertCntr = UIAlertController(title: "Oh no!",
                                                  message: "Your game data if corrupted, will try to rebuild, but may have to reset",
                                                  preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertCntr.addAction(action)
                viewController.present(alertCntr, animated: true, completion: nil)
                try! FileManager.default.removeItem(at: dataFileURL)
                KeychainWrapper.standard.removeObject(forKey: KeyChainSaveKey)
            }
        }
        return nil
    }
    
    func saveGameData(gameData:GameData) throws
    {
        //save to file on the device
        let dataFileURL = documentFolder.appendingPathComponent(gameDataFile)
        let rawData:Data = try JSONEncoder().encode(gameData)
        try rawData.write(to: dataFileURL)
        
        //generate hash of the file and save to key chain
        let hashSring:String = rawData.md5
        //we may have to handle if failue, with try agian or some other technique
        let _:Bool = KeychainWrapper.standard.set(hashSring, forKey: KeyChainSaveKey)
        
        
        //save to game centre & post scores
       
        let player = GameKitHelper.sharedGameKitHelper.getPlayer()
        if player.isAuthenticated
        {
            // go ahead and attempt storage in the cloud, GameCentre
            player.saveGameData(rawData, withName: "SpaceRaider") { (savedGame, error) in
                if error != nil
                {
                    NSLog("Error saving game data to GameCentre %@", (error?.localizedDescription)!)
                }
            }
            //update the score and asuch the leader board.
            
            #if DEVELOPMENT
            let updateScore        = GKScore(leaderboardIdentifier: GamePlayScoreBoards.allTimeHighestDev)
            let updateAlienRescued = GKScore(leaderboardIdentifier: GamePlayScoreBoards.allTimeRescuesDev)
            let updateLootCaptured = GKScore(leaderboardIdentifier: GamePlayScoreBoards.allTimeLootDev)
            #else
            let updateScore        = GKScore(leaderboardIdentifier: GamePlayScoreBoards.allTimeHighest)
            let updateAlienRescued = GKScore(leaderboardIdentifier: GamePlayScoreBoards.allTimeRescues)
            let updateLootCaptured = GKScore(leaderboardIdentifier: GamePlayScoreBoards.allTimeLoot)
            #endif
            
            updateScore.value = Int64(gameData.gameTotalScore)
            updateAlienRescued.value = Int64(gameData.gameTotalRescued)
            updateLootCaptured.value = Int64(gameData.gameTotalLoot)
            
            GKScore.report([updateScore, updateAlienRescued, updateLootCaptured]) { (error) in
                if error != nil
                {
                    NSLog("Leaderboard score posting error %s", (error?.localizedDescription)!)
                }
            }
        }
    }

    // if a game file is not available locally sored or via Game Center
    func createEmptyGameData() -> GameData
    {
        let gameData:GameData = GameData()
        
        return gameData
    }
    
    func createStage() -> GameData.Stage
    {
        return GameData.Stage()
    }
    
    func resetScores()
    {
        let newGameData = createEmptyGameData()
        do {
            try saveGameData(gameData: newGameData)
            resetReload = true
        }
        catch
        {
            NSLog("Unable to reset game data")
        }
    }
    
    func scoresReset()
    {
        resetReload = false //reset flag to false.
    }
}
