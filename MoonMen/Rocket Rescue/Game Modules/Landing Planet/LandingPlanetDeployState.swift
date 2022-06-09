//
//  LandingPlanetDeployState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 14/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class LandingPlanetDeployState: LandingPlanetState {

    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Turn on the indicator light with a green color.
//        print("LandingPlanetDeployState didEnter")
        
        let landingPlanetNode = self.associatedNode
        let xPos = (landingPlanetNode?.size.width)! / 2
        
        let moveTo = SKAction.move(to: CGPoint(x: xPos, y: landingPlanetNode!.yOnScreen!), duration: TimeInterval(1.0))
        let seq    = SKAction.sequence([moveTo])
        
        // depending on whether the rocket land on the land pad or misses, moves to the next state, Landing or Missed,
        landingPlanetNode!.run(seq) {
            let help = UserDefaults.standard.bool(forKey: "helpPrompts")
            if !help  //update to true when testing complete
            {
                let help1 = HelpScreens(game: self.game!, message: "Land here to start rescue")
                let lp = landingPlanetNode?.landingPadSprite?.convert((landingPlanetNode?.landingPadSprite?.position)!, to: self.game!)
                let posX = (lp?.x)! - help1.size.width / 2.0
                let posY = (lp?.y)! + (self.game?.size.height)! * 0.1
                help1.position = CGPoint(x: posX, y: posY)
                self.game?.addChild(help1)
            }
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
//        print("LandingPlanetDeployState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is LandingPlanetLandedState.Type || stateClass is LandingPlanetMissedState.Type
    }
    
    
}
