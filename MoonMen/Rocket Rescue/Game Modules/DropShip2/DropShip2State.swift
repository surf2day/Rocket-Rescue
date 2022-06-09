//
//  DropShip2State.swift
//  MoonMen
//
//  Created by Christopher Bunn on 8/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import SpriteKit
import GameplayKit

class DropShip2State: GKState {
    // MARK: Properties
    
    /// A reference to the game scene, used to alter sprites.
    weak var game: GameScene?
    
    /// The name of the node in the game scene that is associated with this state.
    let associatedNodeName: String = "dropShip2"
    
    /// Convenience property to get the state's associated sprite node.
    var associatedNode: DropShip2? {
        return game?.childNode(withName: "//\(associatedNodeName)") as? DropShip2
    }
   
    
    init(game:GameScene) {
        self.game = game
    }
    
    override func didEnter(from previousState: GKState?) {
//        guard let associatedNode = associatedNode else { return }
//        print("wait state didEnter")
        //if we enter the wait state and the rocked is docked, the dropship stageComplete flag is set to "true" that means the rocket has returned and won
        //if in wait state and ascending, means the rocket is waiting to commence the stage
        // at this point call the scene and update score and go to next step in the stage.
    }
    
    /// Unhighlights the sprite representing the state.
    override func willExit(to nextState: GKState) {
//        guard let associatedNode = associatedNode else { return }
//        print("willExit")
    }
}
