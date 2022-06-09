//
//  RocketGeometryComponent.swift
//  MoonMen
//
//  Created by Christopher Bunn on 13/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class RocketGeometryComponent: GKComponent {
    
    let geometryNode:RescueRocket
    var timeCounter:TimeInterval = 0.0

    init(geometryNode:RescueRocket) {
        self.geometryNode = geometryNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //update delta time, controls the rate a decent and ascent on the clock cycle
    
    override func update(deltaTime seconds: TimeInterval) {
  //      print("deltaTime = \(seconds)")
        
        //only make updates to rocket position every 0.25 of a second
        timeCounter += seconds
        if timeCounter < 0.03 { return }
        timeCounter = 0.0
        switch (geometryNode.ascendingDecending)
        {
        case RocketMode.Decending:
            var pos = self.geometryNode.position
            pos.y -= self.geometryNode.decentRate  // this should be a soft setting, setup in the rocket plist
            self.geometryNode.position = pos
        case RocketMode.Ascending:
            var pos = self.geometryNode.position
            pos.y += self.geometryNode.ascentRate  // this should be a soft setting, setup in the rocket plist
            self.geometryNode.position = pos
            if pos.y - self.geometryNode.size.height / 2.0 > (self.geometryNode.game?.size.height)! // missed the dropship and so game lost
            {
                self.geometryNode.currentHitPoints = 0
                self.geometryNode.game?.missionStatus = MissionStatus.LostToSpace
            }
        case RocketMode.Landed:
            break;
        case RocketMode.Docked:
            break
        case RocketMode.Crashed:
            break
            
        }
        // if rocket off the top of the screen, then mission is lost.
        
        
    }
    
    // impact and crash vectors can be added there
    
}
