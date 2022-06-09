//
//  AlienCollectionNodeComponent.swift
//  Space Raider
//
//  Created by Christopher Bunn on 6/2/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import GameplayKit

class AlienCollectionNodeComponent: GKComponent {

    weak var collectionNode:AlienCollectionNode?
    
    init(collectionNode:AlienCollectionNode)
    {
        self.collectionNode = collectionNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
