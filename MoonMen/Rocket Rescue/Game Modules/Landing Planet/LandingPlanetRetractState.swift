//
//  LandingPlanetRetractState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 14/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class LandingPlanetRetractState: LandingPlanetState {
    
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // animate the moon off the screen
//        print("LandingPlanetRetractState didEnter")
        let landingPlanetNode = self.associatedNode
        let xPos = (landingPlanetNode?.size.width)! / 2
        
        let moveTo = SKAction.move(to: CGPoint(x: xPos, y: landingPlanetNode!.yOffScreen!), duration: TimeInterval(1.0))
        let seq    = SKAction.sequence([moveTo])
        
        //MARK: weak self
        // depending on whether the rocket land on the land pad or misses, moves to the next state, Landing or Missed,
        landingPlanetNode!.run(seq) { [weak self] in
            self?.stateMachine?.enter(LandingPlanetWaitState.self)
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        let help = UserDefaults.standard.bool(forKey: "helpPrompts")
        if !help  //update to true when testing complete
        {
            let help1 = HelpScreens(game: self.game!, message: "Blast your way back to the mothership")
            let posX = (game?.rescueRocket?.position.x)! - ((game?.rescueRocket?.size.width)! / 2.0) - (help1.size.width / 2.0)
            let posY = game?.rescueRocket?.position.y
            help1.position = CGPoint(x: posX, y: posY!)
            self.game?.addChild(help1)
            UserDefaults.standard.set("YES", forKey: "helpPrompts")  //YES means completed
        }
//        print("LandingPlanetRetractState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is LandingPlanetWaitState.Type
    }
}
