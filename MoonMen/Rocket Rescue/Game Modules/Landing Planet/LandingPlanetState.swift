//
//  LandingPlanetState.swift
//  MoonMen
//
//  Created by Christopher Bunn on 14/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class LandingPlanetState: GKState {

    weak var game: GameScene?
    let associatedNodeName:String = "landingPlanetSprite"
    
    /// Convenience property to get the state's associated sprite node.
    var associatedNode: LandingPlanet? {
        return game?.childNode(withName: "//\(associatedNodeName)") as? LandingPlanet
    }
    
    init(game:GameScene) {
        self.game = game
    }
    
    override func didEnter(from previousState: GKState?) {
//        guard let associatedNode = associatedNode else { return }
//        print("didEnter")
    }
    
    /// Unhighlights the sprite representing the state.
    override func willExit(to nextState: GKState) {
//        guard let associatedNode = associatedNode else { return }
//        print("willExit")
    }
    
}
