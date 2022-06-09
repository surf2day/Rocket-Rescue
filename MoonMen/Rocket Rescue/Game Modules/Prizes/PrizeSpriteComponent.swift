//
//  PrizeSpriteComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 19/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameplayKit

class PrizeSpriteComponent: GKComponent {
    
    var prizeNode:PrizeSprite?
    
    init(prizeNode:PrizeSprite)
    {
        self.prizeNode = prizeNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
