//
//  AlienState.swift
//  Space Raider
//
//  Created by Christopher Bunn on 26/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienState: GKState {
    
    weak var game:GameScene?
    var associatedAlienName:String?  //plugged in with the alien object
    
    var associatedAlien: AlienSprite?
    {
        return game?.childNode(withName:associatedAlienName!) as? AlienSprite
    }
    
    init(game:GameScene)
    {
        self.game = game
//        self.associatedAlienName = alienName
    }

    override func didEnter(from previousState: GKState?) {
//        guard let associatedAlien = associatedAlien else { return }
    }
    
    /// Unhighlights the sprite representing the state.
    override func willExit(to nextState: GKState) {
//        guard let associatedAlien = associatedAlien else { return }
    }
    
}
