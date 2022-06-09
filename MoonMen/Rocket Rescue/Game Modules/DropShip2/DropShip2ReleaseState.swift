//
//  DropShip2ReleaseState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 8/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2ReleaseState: DropShip2State
{
    override init(game:GameScene) {
        super.init(game: game)
    }
    
    // MARK: GKState overrides
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
//        print("DropShip2ReleaseState didEnter")
        
        let dropShipNode = self.associatedNode
        
        let wait   = SKAction.wait(forDuration: TimeInterval(0.5))
        let breakJoint = SKAction.run {
            self.game?.hideScores(hide: false)
            dropShipNode!.releaseRocket()
        }
        
        let seq = SKAction.sequence([wait, breakJoint])
        dropShipNode!.run(seq, completion: { [weak self] in
            self?.stateMachine?.enter(DropShip2RetractState.self)
        })
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        // when the game plays for the first time. so a number of help messages instructung on how to play
        // its tracked in the userdefaults,  which checks outside the update loop for performance
        // 3 help points,  DropShip release, landing planet deploy, landing planet retract
        let help = UserDefaults.standard.bool(forKey: "helpPrompts")
        
        if !help  
        {
            let help1 = HelpScreens(game: game!, message: "Decend to the planet below, drop bombs to clear the way")
            var posX = (game?.size.width)! * 0.7
            var posY = (game?.size.height)! * 0.65
            help1.position = CGPoint(x: posX, y: posY)
            self.game?.addChild(help1)
            
            let help2 = HelpScreens(game: game!, message: "Touch screen to drop bombs and fire lasers")
            posY = (game?.size.height)! * 0.3
            help2.position = CGPoint(x: posX, y: posY)
            self.game?.addChild(help2)
            
            let help3 = HelpScreens(game: game!, message: "Control rocket direction")
            let cntrCtlButton = game?.childNode(withName: "centreTopControl") as! MoveControlBox
            posX = cntrCtlButton.position.x
            posY = cntrCtlButton.position.y + (game?.size.height)! * 0.1
            help3.position = CGPoint(x: posX, y: posY)
            self.game?.addChild(help3)

        }
        
//        print("DropShip2ReleaseState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is DropShip2RetractState.Type
    }
}
