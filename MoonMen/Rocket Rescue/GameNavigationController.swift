//
//  GameNavigationController.swift
//  Space Raider
//
//  Created by Christopher Bunn on 20/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit

class GameNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let note = NotificationCenter.default
        note.addObserver(self,
                         selector: #selector(showAuthenticationViewContoller(_:)),
                         name: Notification.Name.PresentAuthenticationViewController,
                         object: nil)
        
        GameKitHelper.sharedGameKitHelper.authenticateLocalPlayer()
    }
    
    
    @objc private func showAuthenticationViewContoller(_ notification:Notification)
    {
        let gameKitHelper = GameKitHelper.sharedGameKitHelper
        self.topViewController?.present(gameKitHelper.authenticationViewController!,
                                        animated: true,
                                        completion: nil)
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}

