//
//  GameSettingsViewController.swift
//  Space Raider
//
//  Created by Christopher Bunn on 12/3/19.
//  Copyright © 2019 Christopher Bunn. All rights reserved.
//

import UIKit
import GameKit
import PersonalizedAdConsent

class GameSettingsViewController: UIViewController {
    
    var parentVC:GameViewController?

    @IBOutlet weak var gameCentre: UIImageView!
    @IBOutlet weak var soundSwitch: UISegmentedControl!
    @IBOutlet weak var addConsentUpdate: UIButton!
    @IBOutlet weak var updateAddPrivacyLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let player = GameKitHelper.sharedGameKitHelper.getPlayer()
        if !player.isAuthenticated
        {
            //grey out the game centre icon
            let i = gameCentre.image
            let gi = grayScaleImage(image: i!)
            gameCentre.image = gi
        }
        
        let onOff = UserDefaults.standard.value(forKey: "backgroundSound") as! String
        if onOff == "ON"
        {
            soundSwitch.selectedSegmentIndex = 0
        }
        else
        {
            soundSwitch.selectedSegmentIndex = 1
        }
        
        //if the device is not in the EEA dont display the add consent update button
        if !PACConsentInformation.sharedInstance.isRequestLocationInEEAOrUnknown
        {
            addConsentUpdate.isHidden = true
            updateAddPrivacyLabel.isHidden = true
        }
    }
    
    private func grayScaleImage(image: UIImage) -> UIImage
    {
        let ciiImage = CIImage(image: image)
        let greyscale = ciiImage?.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0.0])
        return UIImage(ciImage: greyscale!)
    }
    
    @IBAction func backGroundSound(_ sender: UISegmentedControl)
    {
//        0 = ON
//        1 = OFF
        
        let defaults = UserDefaults.standard
        if sender.selectedSegmentIndex  == 0
        {
            defaults.set("ON", forKey: "backgroundSound")
        }
        else
        {
            defaults.set("OFF", forKey: "backgroundSound")
        }
    }
    
    @IBAction func privacyPolicy(_ sender: UIButton)
    {
        if let url = URL(string: "http://www.bigtoelabs.com/privacy-policy")
        {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func credits(_ sender: UIButton)
    {
        if let url = URL(string: "https://www.bigtoelabs.com/home/rocket-raider-sound-credits")
        {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    @IBAction func webSite(_ sender: Any)
    {
        if let url = URL(string: "http://www.bigtoelabs.com/")
        {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    @IBAction func doneButton(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func socreReset(_ sender: UIButton)
    {
        let alertCtr = UIAlertController(title: "Score Reset",
                                         message: "Reset scores to the start",
                                         preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
//            print("reset scores")
            GameDataMrg.sharedGameDataMgr.resetScores()
        }
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        alertCtr.addAction(yes)
        alertCtr.addAction(no)
        self.present(alertCtr, animated: true, completion: nil)
    }
    
    @IBAction func removeAddsPruchase(_ sender: UIButton)
    {
        parentVC?.makePurchase(productString: RocketRescueProducts.addFree)
    }
    
    @IBAction func changePrivacySettings(_ sender: UIButton)
    {
        let privacyURL = URL(string: "https://www.bigtoelabs.com/privacy-policy")
        if let form = PACConsentForm(applicationPrivacyPolicyURL: privacyURL!)
        {
            form.shouldOfferPersonalizedAds = true
            form.shouldOfferNonPersonalizedAds = true
            form.shouldOfferAdFree = true
            form.load(completionHandler: { (error:Error?) in
                if let error = error
                {
                    NSLog("Error loading consent form - %S", error.localizedDescription)
                }
                else
                {
                    form.present(from: self, dismissCompletion: { (error, userPrefersAdFree) in
                        if userPrefersAdFree
                        {
                            self.parentVC?.makePurchase(productString: RocketRescueProducts.addFree)
                        }
                        else if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized
                        {
  //                          let extras = GADExtras()
  //                          extras.additionalParameters = ["npa": "1"]
  //                          gadRequest.register(extras)
  //                          self.bannerView.load(gadRequest)
                        }
                        else
                        {
 //                           self.bannerView.load(gadRequest)
                        }
                    })
                }
            })
        }
        else
        {
            NSLog("Error - privacy url could not be found, url")
        }
    
    }
    
    @IBAction func restorePurchases(_ sender: UIButton)
    {
//        print("restore purchase")
        RocketRescueProducts.store.restorePurchase()
    }
    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */

}
