//
//  DropShip2CaptureState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 8/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2CaptureState: DropShip2State
{
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // add tractor beam to the dropship, for rescuse rocket to land in
        self.associatedNode?.addTractorBeam()
        
//        print("DropShip2CaptureState didEnter")
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // remove the tractor beam
        
//        print("DropShip2CaptureState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is DropShip2RetractState.Type
    }
}
