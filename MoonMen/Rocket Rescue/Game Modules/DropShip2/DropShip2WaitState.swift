//
//  DropShip2WaitState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 8/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2WaitState: DropShip2State
{
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
//        print("DropShip2WaitState didEnter")
        
        // if the is docked that means the rocket has returned and the sub stage is compete
        // mark the stageComplete for the game and during the next update cycle, it will be caught and mission ended.
        if associatedNode!.missionComplete
        {
            game?.missionStatus = .Won
            
        }
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Turn off the indicator light.
        
//         print("DropShip2WaitState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is DropShip2DeployState.Type
    }
}
