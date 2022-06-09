//
//  RocketPlayerControlComponent.swift
//  MoonMen
//
//  Created by Christopher Bunn on 13/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class RocketPlayerControlComponent: GKComponent {

    /// A convenience property for the entity's geometry component.
    var geometryComponent:RocketGeometryComponent? {
        return entity?.component(ofType: RocketGeometryComponent.self)
    }
    
    // this is responsing to rocket movement from player input.
    func moveRocket(direction: MoveRocketDirection)
    {
        let rescueRocket = geometryComponent?.geometryNode
        let moveDistance = rescueRocket!.moveButtonDistance
        var rocketPos = rescueRocket?.position
        
        switch (direction)
        {
        case MoveRocketDirection.Left:
  //          print("MoveRocketDirection.Left")
            //test if rocket is not over the left edge, if on left edge, do not move further
            if ((rocketPos?.x)! - (rescueRocket?.size.width)! / 2) > 0
            {
                rocketPos?.x -= moveDistance!
            }
        case MoveRocketDirection.Right:
 //           print("MoveRocketDirection.Right")
            //test if rocket is not over the right edge, if on right edge, do not move further
            
            if ((rocketPos?.x)! + (rescueRocket?.size.width)! / 2) < (rescueRocket?.game?.size.width)!
            {
                rocketPos?.x += moveDistance!
            }
        case MoveRocketDirection.Up:
 //           print("MoveRocketDirection.Up")
            // change image to the boster image, only change if needed
            let tex = SKTexture(imageNamed: (rescueRocket?.imageBooster)!)
            rescueRocket?.texture = tex
            rescueRocket?.size = tex.size()
            
            if rescueRocket?.ascendingDecending == RocketMode.Decending   // decrease the rate of decent by half the value of decent, ie 1/2 the rate.
            {
                rocketPos?.y += (rescueRocket?.bosterRate)! / 2 
            } else // increase the rate of ascent, by half the rate of ascent ie 1.5*
            {
                rocketPos?.y += rescueRocket!.ascentRate + (rescueRocket?.bosterRate)!
            }
        case MoveRocketDirection.Down:
  //          print("MoveRocketDirection.Down")
  //          rocketPos?.y -= moveDistance!
            rocketPos?.y -= 1
            
        case MoveRocketDirection.None:
 //           print("MoveRocketDirection.None")
            //only chnage the image if needed.
            let tex = SKTexture(imageNamed: (rescueRocket?.imageStandard)!)
            rescueRocket?.texture = tex
            rescueRocket?.size = tex.size()
        }
        rescueRocket?.position = rocketPos!
    }
}
