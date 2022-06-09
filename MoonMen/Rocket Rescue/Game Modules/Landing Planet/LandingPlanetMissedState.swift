//
//  LandingPlanetMissedState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 14/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class LandingPlanetMissedState: LandingPlanetState {
    
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // at this point handle the crash of the ship onto the moon and whatever i decide to do at this point in the game.
        // probably give a try again option
        
 //       print("LandingPlanetMissedState didEnter")
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        
//        print("LandingPlanetMissedState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is LandingPlanetRetractState.Type
    }
}
