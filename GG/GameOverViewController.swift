import UIKit
import SpriteKit
import GameKit
import iAd

class GameOverViewController: UIViewController, GKGameCenterControllerDelegate, ADBannerViewDelegate {
    let APP_ID = 1081143952;
    var viewController: GameOverViewController!
    var bannerView: ADBannerView!
    
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var bestScoreLbl: UILabel!
    @IBOutlet var scoreConst: NSLayoutConstraint!
    @IBOutlet var buttonsConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        changeConstraintForScoresBasedOnScreenSize()
        var scoreStr = String(mainInstance.score)
        scoreLbl.text = scoreStr
        saveHighscore(mainInstance.score)
        checkAndSaveBestScore()
        bestScoreLbl.text = String(highScore())
        
        bannerView = ADBannerView(adType: .Banner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self
        bannerView.hidden = true
        view.addSubview(bannerView)
        
        let viewsDictionary = ["bannerView": bannerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
    }

    @IBAction func rateAppBtn(sender: AnyObject) {
        rateApp()
    }
    
    @IBAction func replayGameLbl(sender: AnyObject) {
        self.performSegueWithIdentifier("showGame", sender: nil)
    }
    
    @IBAction func scoreboardLbl(sender: AnyObject) {
        saveHighscore(mainInstance.score)
        showLeaderboardScreen()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        bannerView.hidden = true
    }
    
    func changeConstraintForScoresBasedOnScreenSize() {
        if UIDevice().userInterfaceIdiom == .Phone {
            switch UIScreen.mainScreen().nativeBounds.height {
            case 960:
                //print("iPhone 4 or 4S")
                self.scoreConst.constant=63
                self.buttonsConst.constant=5
            case 1136:
                //print("iPhone 5 or 5S or 5C")
                self.scoreConst.constant=65
                self.buttonsConst.constant=5
            case 1334:
                //print("iPhone 6 or 6S")
                self.scoreConst.constant=84
            //case 2208:
                //print("iPhone 6+ or 6S+")
            default:
                self.scoreConst.constant=81
            }
        }
    }
    
    func saveHighScore(high:Int) {
        NSUserDefaults.standardUserDefaults().setInteger(high, forKey: "highscore")
    }
    
    func highScore() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    }
    
    func resetHighScore() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("highscore")
    }
    
    func checkAndSaveBestScore() {
        if mainInstance.score > highScore() {
            saveHighScore(mainInstance.score)
            //print("New Highscore = " + highScore().description)
        } else {
            //print("HighScore = " + highScore().description)
        }
        
        if mainInstance.score > highScore() {
            saveHighScore(mainInstance.score)
        } else {
            //print("HighScore = " + highScore().description)
        }
    }
    
    func rateApp() {
        UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!);
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveHighscore(score: Int) {
        // check if user is signed in
        if GKLocalPlayer.localPlayer().authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "angrynan") // leaderboard id here
            scoreReporter.value = Int64(score) // score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.reportScores(scoreArray, withCompletionHandler: {(NSError) -> Void in
                if NSError != nil {
                    print(NSError!.localizedDescription)
                }
            })
        }
    }
    
    func showLeaderboardScreen() {
        let vc = self
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc.presentViewController(gc, animated: true, completion: nil)
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            } else {
                print((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}