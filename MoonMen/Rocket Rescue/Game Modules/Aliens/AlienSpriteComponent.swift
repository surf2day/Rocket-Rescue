//
//  AllienSpriteComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 27/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienSpriteComponent: GKComponent {

    weak var alienNode:AlienSprite?
    
    init(alienNode:AlienSprite)
    {
        self.alienNode = alienNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
