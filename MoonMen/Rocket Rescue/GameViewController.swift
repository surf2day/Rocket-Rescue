//
//  GameViewController.swift
//  MoonMen
//
//  Created by Christopher Bunn on 30/10/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

import GoogleMobileAds
import PersonalizedAdConsent

import StoreKit

 import AdSupport

class GameViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GADBannerView! = nil
    
    var products: [SKProduct] = []   // holds all products that are availabe with Rocket Rescue
    
    let sceneScaleFactor:CGFloat = 1.81
    var screenWidth:CGFloat
    {
        return UIScreen.main.bounds.width
    }
    var screenHeight:CGFloat
    {
        return UIScreen.main.bounds.height
    }
    var sceneHeight:CGFloat
    {
        return sceneScaleFactor * screenHeight
    }
    var sceneWidth:CGFloat
    {
        return sceneScaleFactor * screenWidth
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.

        let skView = self.view as! SKView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        
        // Create and configure the scene.
        let scene = StartScene(fileNamed: "StartScene")
        scene?.parentVC = self
 /*       let sceneScaleFactor:CGFloat = 1.81
        let sceneHeight = sceneScaleFactor * screenHeight
        let sceneWidth  = sceneScaleFactor * screenWidth */
        
        scene!.size = CGSize(width: sceneWidth, height: sceneHeight)
        scene!.scaleMode = .aspectFill
        // for model X and alike the edgeLoop needs to be modified to cater for the black screen intrusion
        let w = UIApplication.shared.keyWindow
        //SKScene is 1.81 times larger than the ViewCOntroller as such a calculation between the two is necessary to make banners, safe area and SKScene
        let topPadding = ((w?.safeAreaInsets.top)! + kGADAdSizeBanner.size.height) * 1.81  //safe area plus the height of the Google add
        let sceneFrame = scene?.frame
        let rect = CGRect(x: (scene?.frame.origin.x)! , y: (scene?.frame.origin.y)!, width: (sceneFrame?.size.width)!, height: (sceneFrame?.size.height)! - topPadding)
        scene!.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        
        //add notification so when purcahses are made suitable actions can be taken, that are needed.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleFailedPurchaseNotification(_:)),
                                               name: .IAPHelperFailedPurchaseNotification,
                                               object: nil)
        
        //if the player has already purchased add free play then, ignore all the google add set up
        if RocketRescueProducts.store.isProductPurchased(RocketRescueProducts.addFree)
        {
            skView.presentScene(scene)
            return
        }
        
        // setup up google adds and request and add
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        #if DEVELOPMENT
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"  //testing ID
        #else
        bannerView.adUnitID = "ca-app-pub-4144460985385396/5046699312"  //production ID
        #endif
        bannerView.rootViewController = self
        bannerView.delegate = self
        let gadRequest = GADRequest()
        
  //            bannerView.isHidden = true   // to remove add for screen shotting
        
        // check add consent, if not in the EU than nothing to be done, if in EU and not consented, present the consent banner.
        
        //for testing on a hardware device.
 //       NSLog("Advertising ID: %@", ASIdentifierManager.shared().advertisingIdentifier.uuidString);
 //       let aid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
 //       PACConsentInformation.sharedInstance.debugIdentifiers = [aid]
 //       PACConsentInformation.sharedInstance.debugGeography = PACDebugGeography.EEA
        
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: ["pub-4144460985385396"]) { (error:Error?) in
            if let error = error
            {
                NSLog("requestConsentInfoUpdate failure %s", error.localizedDescription)
            }
            else
            {
                // check id player is in the EU, if yes, check consent, if not request consent.
                //if not in the EU or consent is set to personalised then no consent required
                
                if !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown || PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.personalized
                {
                    self.bannerView.load(gadRequest)
                }
                else if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized
                {
                    let extras = GADExtras()
                    extras.additionalParameters = ["npa": "1"]
                    gadRequest.register(extras)
                    self.bannerView.load(gadRequest)
                }
                else if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown  // present consent form and act on consent as appropiate
                {
                    self.showAddDecisionBanner()
                }
            }
        }
        
 /*       let outLine = SKShapeNode(rect: rect)
        outLine.lineWidth = 5
        outLine.strokeColor = .white
        scene?.addChild(outLine) */
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    //google banner providing options to the player for add choice
    func showAddDecisionBanner()
    {
        let gadRequest = GADRequest()
        let privacyURL = URL(string: "https://www.bigtoelabs.com/privacy-policy")
        if let form = PACConsentForm(applicationPrivacyPolicyURL: privacyURL!)
        {
            form.shouldOfferPersonalizedAds = true
            form.shouldOfferNonPersonalizedAds = true
            //check if the devices can make a payment, parent controls can disable the ability to purchase
            if IAPHelper.canMakePayments()
            {
                form.shouldOfferAdFree = true
            }
            else
            {
                form.shouldOfferAdFree = false
            }
            form.load(completionHandler: { (error:Error?) in
                if let error = error
                {
                    NSLog("Error loading consent form - %S", error.localizedDescription)
                    self.bannerView.load(gadRequest) // this might need to be removed, or changed to non personalised at the least
                }
                else
                {
                    // should only present the add banner if nothing else presented, typically this could be the game centre login screen.
                    //need to determin how to wait for the view controller to clear.
                    if self.presentedViewController != nil
                    {
                        var cntr = 0
                        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (timer) in
                            if cntr > 20  // max number of tries, ie 1 minute
                            {
                                timer.invalidate()
                            }
                            if self.presentedViewController == nil //game centre login complete
                            {
//                                print("gameCentre done")
                                timer.invalidate()
                                self.presentForm(form: form, gadRequest: gadRequest)
                            }
                            cntr += 1
                        })
                        
                        print("already presening a alert or game center")
                    }
                    else
                    {
                        // no game center login displayed
                        self.presentForm(form: form, gadRequest: gadRequest)
                    }
                }
            })
        }
        else
        {
            NSLog("Error - privacy url could not be found, url")
        }
    }
    
    private func presentForm(form: PACConsentForm, gadRequest: GADRequest)
    {
        form.present(from: self, dismissCompletion: { (error, userPrefersAdFree) in
            if userPrefersAdFree
            {
                //                          print("buy the add free")
                RocketRescueProducts.store.requestProducts{ [weak self] success, products in
                    guard let self = self else { return }
                    if success
                    {
                        self.products = products!
                        let addfreeProduct = self.products.first(where: { (prod) -> Bool in
                            if prod.productIdentifier == RocketRescueProducts.addFree
                            {
                                return true
                            }
                            return false
                        })
                        if addfreeProduct != nil
                        {
                            //                                      print("purchase ")
                            // the add free version should only be availabe if the purchase is completed.
                            RocketRescueProducts.store.buyProduct(addfreeProduct!)
                        }
                    }
                }
            }
            else if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized
            {
                let extras = GADExtras()
                extras.additionalParameters = ["npa": "1"]
                gadRequest.register(extras)
                self.bannerView.load(gadRequest)
            }
            else
            {
                self.bannerView.load(gadRequest)
            }
        })
    }
    
    func setEEAUnderageFlag()
    {
        if PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown
        {
            PACConsentInformation.sharedInstance.isTaggedForUnderAgeOfConsent = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: delegate handlers for Google Adds
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("received an add")
        let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets
        
        //note here safe area is in the cordinates of the ViewController, where as the SKScene cordinates are 1.81 times larger, ie VC is 750, SKScene is 750 * 1.81
        bannerView.frame.origin.y = (safeArea?.top)!                 //adjust the add placement to be below the black screen insert in iphone X and alike
        
        let cntrX = self.view.frame.size.width / 2
        bannerView.center.x = cntrX
        
        self.view?.addSubview(bannerView)
    }
    
    func makePurchase(productString: String)
    {
        RocketRescueProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success
            {
                self.products = products!
                let addfreeProduct = self.products.first(where: { (prod) -> Bool in
                    if prod.productIdentifier == productString // RocketRescueProducts.addFree
                    {
                        return true
                    }
                    return false
                })
                if addfreeProduct != nil
                {
                    // the add free version should only be availabe if the purchase is completed.
                    RocketRescueProducts.store.buyProduct(addfreeProduct!)
                }
            }
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("add request failed: \(error.localizedDescription)")
    }
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    // MARK: notification handler for when purchases have been completed.
    
    @objc func handlePurchaseNotification(_ notification: Notification)
    {
        let productId = notification.object as? String
        //in the event an add free purchase has been made, the adds banner needs to be deactivated.
        if productId == RocketRescueProducts.addFree
        {
            //remove advertising, only way i can find to handle this is nil the delegate and
            if bannerView != nil
            {
                bannerView.delegate = nil
                bannerView.removeFromSuperview()
                bannerView = nil
            }
        }
    }
    
    //failed purchase handler,   addFree failed purchased results with altering the user to the failer and then representing the google add permission banner.
    @objc func handleFailedPurchaseNotification(_ notification: Notification)
    {
        let productId = notification.object as? String
        //in the event an add free purchase has been made, the adds banner needs to be deactivated.
        if productId == RocketRescueProducts.addFree
        {
            let alert = UIAlertController(title: "Purchase Failed", message: "Add Free purchased failed", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                self.showAddDecisionBanner()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
