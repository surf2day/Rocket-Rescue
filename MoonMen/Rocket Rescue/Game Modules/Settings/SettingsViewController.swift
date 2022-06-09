//
//  SettingsViewController.swift
//  Space Raider
//
//  Created by Christopher Bunn on 9/12/18.
//  Copyright © 2018 Christopher Bunn. All rights reserved.
//

import UIKit
import GameKit

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, GKGameCenterControllerDelegate {
    
    var parentVC:GameViewController?
    
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var totalLoot:UILabel!
    @IBOutlet weak var totalRescued:UILabel!
    
    //summary of stages
    @IBOutlet weak var stageCollectionView: UICollectionView!
    @IBOutlet weak var stageCollectionViewFlow: UICollectionViewFlowLayout!
    
    @IBOutlet weak var missionSummary: UIImageView!
    
    @IBOutlet weak var missionTitle: UILabel!
    @IBOutlet weak var missionScore: UILabel!
    @IBOutlet weak var missionRescued: UILabel!
    @IBOutlet weak var missionLoot: UILabel!
    @IBOutlet weak var missionImage: UIImageView!
    
    //leaderboard collection view
    @IBOutlet weak var leaderBoardTableView: UITableView!
    
    var allTimeLeaderBoardScores:[GKScore] = [];
    
    var gameData:GameData?
    
    var score:Int = 0
    {
        didSet
        {
            self.totalScore.text = "Score - " + String(score)
        }
    }
    var loot:Int = 0
    {
        didSet
        {
            self.totalLoot.text = "Loot - " + String(loot)
        }
    }
    var rescued:Int = 0
    {
        didSet
        {
            self.totalRescued.text = "Rescued - " + String(rescued)
        }
    }
    
    //data source for the stage and mission layout
    var stageLayout: Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameData = GameDataMrg.sharedGameDataMgr.loadGameData(viewController:self)
        
        // retrieve leader board information
 //       self.loadScores()
        leaderBoardTableView.isHidden = true
        
//        let currentStage = gd.stages.last
/*        self.score = gd.gameTotalScore
        self.loot = gd.gameTotalLoot
        self.rescued = gd.gameTotalRescued */
        
        //load stage and mission data for the player to scroll through in the collection view
        let file = Bundle.main.path(forResource: GameConfiguration.StageMapFile, ofType: nil)
        stageLayout = NSDictionary(contentsOfFile: file!) as? [String:Any]
        
        missionSummary.isHidden = true
        missionSummary.layer.masksToBounds = true
        missionSummary.layer.cornerRadius = 5
        
        missionSummary.image = #imageLiteral(resourceName: "settings-missionSummary")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.missionSummaryTap(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        missionSummary.addGestureRecognizer(tap)
        
        //round the corners on the TableView and collection view
        stageCollectionView.layer.cornerRadius = 5.0
        stageCollectionView.clipsToBounds = true
        
        leaderBoardTableView.isHidden = true //not visible until implemented, not yet implemented
/*        leaderBoardTableView.layer.cornerRadius = 5.0
        leaderBoardTableView.clipsToBounds = true
        leaderBoardTableView.separatorColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1) */
        
        let cfl = UICollectionViewFlowLayout()
        cfl.minimumLineSpacing = 5
        cfl.minimumInteritemSpacing = 5
        cfl.sectionInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        let w = stageCollectionView.frame.width / 5
        cfl.estimatedItemSize = CGSize(width: w, height: w)
        let headWidth = stageCollectionView.frame.width
        let headHeight = stageCollectionView.frame.height * 0.1
        cfl.headerReferenceSize = CGSize(width: headWidth, height: headHeight)
        stageCollectionView.collectionViewLayout = cfl
    }
    
    @IBAction func launchButtonTapped(_ sender:UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButton(_ sender: UIButton)
    {
        let aItem = ImageShareMessage(placeholderItem: "default" as AnyObject)
        let aItem2 = TextShareMessage(placeholderItem: "default" as AnyObject)
        
        let ac = UIActivityViewController(activityItems: [aItem, aItem2], applicationActivities: nil)

        ac.excludedActivityTypes = [.addToReadingList, .assignToContact, .copyToPasteboard, .openInIBooks, .postToVimeo, .markupAsPDF]
        ac.setValue("Play Rescue Rocket", forKey: "subject") //add a subject in email
        
        present(ac, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        // if the game has been reset then the tableview needs to be reset and scores need to be reset.
        
        gameData = GameDataMrg.sharedGameDataMgr.loadGameData(viewController:self)
        if gameData != nil
        {
            self.score = (gameData?.gameTotalScore)!
            self.loot = (gameData?.gameTotalLoot)!
            self.rescued = (gameData?.gameTotalRescued)!
            stageCollectionView.reloadData()
        }
        else
        {
            self.totalScore.text   = "Score   - No game data"
            self.totalLoot.text    = "Loot    - No game data"
            self.totalRescued.text = "Rescued - No game data"
        }
    }
    
    @IBAction func scoresButton(_ sender: Any)
    {
        let gcc = GKGameCenterViewController()
        gcc.viewState = .default
        gcc.leaderboardIdentifier = GamePlayScoreBoards.allTimeHighest
        gcc.gameCenterDelegate = self
        gcc.view.backgroundColor = #colorLiteral(red: 0.7490196078, green: 0.8509803922, blue: 1, alpha: 1)
        
        self.present(gcc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
       gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Collection View handlers
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let i = stageLayout?.count
        return i!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let section = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader , withReuseIdentifier: "stageHeader", for: indexPath) as! CollectionSectionHeader
        
        let stage = "stage" + String(indexPath.section)
        let stageContents = stageLayout?[stage] as! [String:Any]
        let stageTitle = stageContents["stageTitle"] as! String
        section.title = stageTitle
        
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let stage = "stage" + String(section)
        let stageContents = stageLayout?[stage] as! [String:Any]
        let missions = stageContents["missions"] as! Array<Dictionary<String, String>>
        let i = missions.count
        return i
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "missionCell", for: indexPath) as! MissionCollectionViewCell
        cell.completed = false //reset this bool to avoid not greying out, non completed missions
        
        let stage = "stage" + String(indexPath.section)
        let stageContents = stageLayout?[stage] as! [String:Any]
        let missions = stageContents["missions"] as! Array<Dictionary<String, String>>
        let mission = missions[indexPath.row]
        
        // check the game progress, display uncompleted missions in greyed out cell.
        if gameData != nil
        {
            
        if indexPath.section < (gameData?.stages.count)!
        {
            let gameStage = gameData?.stages[indexPath.section]
            if indexPath.row < (gameStage?.missions.count)!
            {
                let gameMission = gameStage?.missions[indexPath.row]
                cell.completed = gameMission!.completed
            }
        }
        }
        cell.name = mission["name"]
        cell.image = mission["image"]
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegate handlers
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        // only allow selection if the mission has been completed.
        let cell = collectionView.cellForItem(at: indexPath) as! MissionCollectionViewCell
        
        if cell.completed
        {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //fillout missionSummary
        if indexPath.section < (gameData?.stages.count)!
        {
            let gameStage = gameData?.stages[indexPath.section]
            if indexPath.row < (gameStage?.missions.count)!
            {
                let mission = gameStage?.missions[indexPath.row]                //game score details
                missionScore.text   = "Score   - \(mission?.bestScore ?? 0)"
                missionLoot.text    = "Loot    - \(mission?.totalLoot ?? 0)"
                missionRescued.text = "Rescued - \(mission?.numberRescued ?? 0)"
                
                let stage = "stage" + String(indexPath.section)                 //general stage information
                let stageContents = stageLayout?[stage] as! [String:Any]
                let missions = stageContents["missions"] as! Array<Dictionary<String, String>>
                let m = missions[indexPath.row]
                missionTitle.text = m["name"]
                missionImage.image = UIImage(named: m["image"]!)
                missionSummary.isHidden = false
            }
        }
    }
    
    @objc func missionSummaryTap(_ sender:UITapGestureRecognizer)
    {
        missionSummary.isHidden = true
    }
    
    //retrieve the leaderboard data
    func loadScores()
    {
        // error handling required here for ocasion when player is not authenticated.
        
        let player = GameKitHelper.sharedGameKitHelper.getPlayer()
        
        let allTimeRequest = GKLeaderboard(players: [player])
        allTimeRequest.identifier = GamePlayScoreBoards.allTimeHighest
        allTimeRequest.loadScores { (scores, error) in
 //           print("rtn from leader board request")
            if let c = scores?.count
            {
                if error == nil && c > 0
                {
                    self.allTimeLeaderBoardScores = scores!
                    self.leaderBoardTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Leaderboards tableview handlers
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTimeLeaderBoardScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderBoardCell") as! LeaderBoardTableViewCell
        
        let pn:String = (indexPath.row + 1).description + ". " + (self.allTimeLeaderBoardScores[indexPath.row].player?.alias)!
        
        cell.playerName.text = pn
        cell.playerScore.text = self.allTimeLeaderBoardScores[indexPath.row].formattedValue
        
        let df = DateFormatter()
        df.dateStyle = .long
        cell.scoreDate.text =  df.string(from: self.allTimeLeaderBoardScores[indexPath.row].date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as! SectionHeaderViewCell
        
        if self.allTimeLeaderBoardScores.indices.contains(section)
        {
            cell.sectionTitle.text = self.allTimeLeaderBoardScores[section].leaderboardIdentifier
        }
        else
        {
            cell.sectionTitle.text = "No leader board data"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let h = tableView.frame.size.height * 0.2
        return h
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let dest = segue.destination.childViewControllers.filter { (viewCtr) -> Bool in
            if viewCtr.isKind(of: GameSettingsViewController.self)
                { return true }
            
            return false
        }
        let vc = dest.first as! GameSettingsViewController
        vc.parentVC = self.parentVC
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

// MARK: UIActivityItemProvider subclass for providing customised
class ImageShareMessage: UIActivityItemProvider
{
    var image = #imageLiteral(resourceName: "shareImage")
    
    init(placeholderItem: AnyObject)
    {
        super.init(placeholderItem: placeholderItem)
    }
    
    public override var item:Any
    {
        switch (self.activityType!)
        {
        case UIActivity.ActivityType.postToFacebook:
            return ()
        case UIActivity.ActivityType.postToTwitter:
            return image
        case UIActivity.ActivityType.mail:
            return image
        case UIActivity.ActivityType.message:
            return image
        default:
            return image
        }
    }
}

class TextShareMessage: UIActivityItemProvider
{
    let txt2 = "Rescue Rocket at the app store http://www.bigtoelabs.com"  //change the URL to the app store url
    
    let fbookText = "https://www.bigtoelabs.com/support/rocket-raider"
    
    init(placeholderItem: AnyObject)
    {
        super.init(placeholderItem: placeholderItem)
    }
    
    public override var item:Any
    {
        switch (self.activityType!)
        {
        case UIActivity.ActivityType.postToFacebook:
            return fbookText
        case UIActivity.ActivityType.postToTwitter:
            return txt2
        case UIActivity.ActivityType.mail:
            return txt2
        case UIActivity.ActivityType.message:
            return txt2
        default:
            return ()
        }
    }
    
}
