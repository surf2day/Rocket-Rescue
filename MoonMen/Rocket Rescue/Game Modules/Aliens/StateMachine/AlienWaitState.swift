//
//  AlienWaitState.swift
//  Space Raider
//
//  Created by Christopher Bunn on 26/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienWaitState: AlienState {
    
    override init(game: GameScene)
    {
        super.init(game: game)
    }
    
    override func didEnter(from previousState: GKState?) {
        super.didEnter(from: previousState)
        
        //generate  the animate on sequence of movements, ready for the next state animateState to run them.
        
        let leftORRight = GKRandomDistribution(lowestValue: 0, highestValue: 100).nextBool()
        
        
        let randY = GKRandomDistribution(lowestValue: Int(-1 * (associatedAlien?.size.height)!), highestValue: Int((game?.size.height)! + (associatedAlien?.size.height)!))
        let yPos = randY.nextInt()
        var xPos = 0
        if leftORRight == true  //x position > scene width and y < 0
        {
            let randX = GKRandomDistribution(lowestValue: Int((game?.size.width)! + (associatedAlien?.size.width)!) , highestValue: Int((game?.size.width)! + (associatedAlien?.size.width)! * 2))
            xPos = randX.nextInt()
        }
        else // x position < scene width an y < 0
        {
            let randX = GKRandomDistribution(lowestValue: Int(-1 * (associatedAlien?.size.width)!) , highestValue: Int((associatedAlien?.size.width)! * -2))
            xPos = randX.nextInt()
        }
        associatedAlien?.position = CGPoint(x: xPos, y: yPos)
        
        
        
        //determine position to appear on screen
 //       let randOnX = GKRandomDistribution(lowestValue: Int((associatedAlien?.size.width)!) / 2, highestValue: Int((game?.size.width)!) -  Int((associatedAlien?.size.width)!) / 2).nextInt()
 //       let randOnY = GKRandomDistribution(lowestValue: Int((game?.landingPlanet?.size.height)!) + Int((associatedAlien?.size.height)!) / 2, highestValue: Int((game?.size.height)! * 0.7)).nextInt()
        
//        associatedAlien?.actionOn = SKAction.move(to: CGPoint(x: randOnX, y: randOnY), duration: 0.25)
       
    }
    
    override func willExit(to nextState: GKState) {
        super.willExit(to: nextState)
        
        
 //       print("AlienWaitState willExit")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // This state can only transition to the serve state.
        return stateClass is AlienFlyingState.Type
    }
    
}
