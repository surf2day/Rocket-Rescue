//
//  DropShip2DeployState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 8/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2DeployState: DropShip2State
{
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        // Turn on the indicator light with a green color.
//        print("DropShip2DeployState didEnter")
        
        let dropShipNode = self.associatedNode
        
        let moveTo = SKAction.move(to: CGPoint(x: dropShipNode!.xPos!, y: dropShipNode!.yOnScreen!), duration: TimeInterval(0.5))
        let wait   = SKAction.wait(forDuration: TimeInterval(0.5))
        let seq    = SKAction.sequence([wait, moveTo])
        
        //hide the banner adds while the drop ship is deployed.
        if let banner = game?.parentVC?.bannerView
        {
            banner.isHidden = true
        }
        dropShipNode!.run(seq, completion: { [weak self] in
            if self?.associatedNode?.joint != nil //only proceed to release if a joint is in place, if rescue rocket attached
            {
                self?.stateMachine?.enter(DropShip2ReleaseState.self)
            }
            else
            {
                self?.stateMachine?.enter(DropShip2CaptureState.self)
            }
        })
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
//        print("DropShip2DeployState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is DropShip2CaptureState.Type || stateClass is DropShip2ReleaseState.Type
    }
}
