//
//  AlienAnimateOffState.swift
//  Space Raider
//
//  Created by Christopher Bunn on 26/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienAnimateOffState: AlienState {
    
    override init(game: GameScene)
    {
        super.init(game: game)
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        //alien was not destroyed but rocket has landed or docked, remaining aliens are animated off the screen
        
//        print("AlienAnimateOffState didEnter")
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        
//        print("AlienAnimateOffState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is AlienWaitState.Type
    }
}
