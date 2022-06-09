//
//  DropShip2RetractState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 8/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2RetractState: DropShip2State
{
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
//        print("DropShip2RetractState didEnter")
        let dropShipNode = self.associatedNode
        
        let moveTo = SKAction.move(to: CGPoint(x: dropShipNode!.xPos!, y: dropShipNode!.yOffScreen!), duration: TimeInterval(0.75))
        let wait   = SKAction.wait(forDuration: TimeInterval(0.5))
        let seq    = SKAction.sequence([wait, moveTo])
        
        dropShipNode!.run(seq, completion: { [weak self] in
            if let banner = self?.game?.parentVC?.bannerView
            {
                banner.isHidden = false
            }
  //          self?.game?.parentVC?.bannerView.isHidden = true // remove banner view for screen shotting
            
            self?.stateMachine?.enter(DropShip2WaitState.self)
        })
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // Turn off the indicator light.
        
//        print("DropShip2RetractState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is DropShip2WaitState.Type
    }
}

