//
//  GameKitHelper.swift
//  Space Raider
//
//  Created by Christopher Bunn on 20/11/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import GameKit
import CoreFoundation

extension Notification.Name
{
    public static let PresentAuthenticationViewController = Notification.Name("present_authentication_view_controller")
}

class GameKitHelper: NSObject
{
    var authenticationViewController:UIViewController?
    var lastError:Error?
    
    var _enableGameCenter:Bool?
    static let sharedGameKitHelper = GameKitHelper()
    
    override init() {
        super.init()
        _enableGameCenter = true
    }
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            self.lastError = error
            if viewController != nil
            {
                self.setAuthenticationViewController(authenticationVC: viewController)
            }
            else if GKLocalPlayer.localPlayer().isAuthenticated
            {
                self._enableGameCenter = true
            }
            else
            {
                self._enableGameCenter = false
            }
        }
    }
    
    func setAuthenticationViewController(authenticationVC:UIViewController?)
    {
        if authenticationVC != nil
        {
            authenticationViewController = authenticationVC
            NotificationCenter.default.post(name: NSNotification.Name.PresentAuthenticationViewController, object: self)
        }
    }
    
    func getPlayer() -> GKLocalPlayer {
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        return localPlayer
    }

    
    
}
