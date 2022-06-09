//
//  AlienFlyingState.swift
//  Space Raider
//
//  Created by Christopher Bunn on 26/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienFlyingState: AlienState {

    override init(game: GameScene)
    {
        super.init(game: game)
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        
        //animate onto the screen
//        associatedAlien?.run((associatedAlien?.actionOn)!)
        
        //start the flying animations if there is one.
        
        
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is AlienDeadRemovalState.Type || stateClass is AlienAnimateOffState.Type || stateClass is AlienWaitState.Type
    }
}
