//
//  ScoreKeeper.swift
//  MoonMen
//
//  Created by Christopher Bunn on 30/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit
import SpriteKit

class ScoreKeeper: SKNode {
    var mainScore:Int = 0
    var lootScore:Int = 0
    var numberRescued:Int = 0
    
    var level:Int = 0
    var scoreBoard:SKLabelNode?
    
    override init() {
        scoreBoard = SKLabelNode(text: "0")
        scoreBoard?.fontName = "HelveticaNeue-CondensedBlack"
        scoreBoard?.fontSize = 48
        super.init()
        self.name = "ScoreBoard"
        addChild(scoreBoard!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPoints(points: Int)
    {
        mainScore += points
        scoreBoard?.text = String(mainScore)
        
    }
    
}
