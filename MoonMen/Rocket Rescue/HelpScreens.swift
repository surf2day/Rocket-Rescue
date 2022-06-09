//
//  HelpScreens.swift
//  Space Raider
//
//  Created by Christopher Bunn on 17/3/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import SpriteKit

// when the game plays for the first time. so a number of help messages instructung on how to play
// its tracked in the userdefaults,  which checks outside the update loop for performance
// 3 help points,  DropShip release, landing planet deploy, landing planet retract


class HelpScreens: SKSpriteNode
{
    weak var game:GameScene?
    
    init(game: GameScene, message: String)
    {
        let help1 = SKLabelNode(fontNamed: "CURSED TIMER ULIL")
        help1.text = message
        help1.name = "helpMessage"
        help1.fontSize = 32
        help1.horizontalAlignmentMode = .center
        help1.fontColor = #colorLiteral(red: 1, green: 0.831372549, blue: 0.1647058824, alpha: 1)
        help1.numberOfLines = 3
        help1.lineBreakMode = .byWordWrapping
        help1.preferredMaxLayoutWidth = 250
        help1.position = CGPoint(x: 0, y: help1.frame.size.height / -2.0)
        help1.zPosition = LayerLevel.HelpScreen + 1
        
        let tex = SKTexture(imageNamed: "helpScreen")
        super.init(texture: tex, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), size: CGSize(width: help1.frame.size.width * 1.15, height: help1.frame.size.height * 1.15))
        
        self.game = game
        self.alpha = 1.0
        self.addChild(help1)
        self.zPosition = LayerLevel.HelpScreen
        self.name = "helpScreen"
        game.isPaused = true
        game.pauseButton?.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        game?.isPaused = false
        game?.pauseButton?.isHidden = false
        self.removeAllChildren()
    }
}
