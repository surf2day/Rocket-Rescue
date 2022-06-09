//
//  BombSpriteComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 21/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class BombSpriteComponent: GKComponent
{
    weak var bombNode:BombSprite?
    
    init(bombNode:BombSprite)
    {
        self.bombNode = bombNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
