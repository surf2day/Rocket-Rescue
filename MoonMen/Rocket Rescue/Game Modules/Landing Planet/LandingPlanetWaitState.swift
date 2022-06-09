//
//  LandingPlanetWaitState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 14/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class LandingPlanetWaitState: LandingPlanetState {
    
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        
//        print("LandingPlanetWaitState didEnter")
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        
//        print("LandingPlanetWaitState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is LandingPlanetDeployState.Type
    }
}
