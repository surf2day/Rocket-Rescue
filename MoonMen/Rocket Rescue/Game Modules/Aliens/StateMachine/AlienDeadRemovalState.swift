//
//  AlienDeadRemovalState.swift
//  Space Raider
//
//  Created by Christopher Bunn on 26/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienDeadRemovalState: AlienState {

    override init(game: GameScene)
    {
        super.init(game: game)
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        //execute the death animation and sounds of the alien
        
//        print("AlienDeadRemovalState didEnter")
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        
//        print("AlienDeadRemovalState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is AlienWaitState.Type
    }
}
