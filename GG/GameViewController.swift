import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, GameOverDelegate, ADBannerViewDelegate {
    var scene: GameScene!
    var bannerView: ADBannerView!
    
    @IBOutlet var gameSceneView: SKView!
    @IBOutlet var backgroundInst: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView = ADBannerView(adType: .Banner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.delegate = self
        bannerView.hidden = true
        view.addSubview(bannerView)

        let viewsDictionary = ["bannerView": bannerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bannerView]|", options: [], metrics: nil, views: viewsDictionary))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "removeInst:")
        backgroundInst.addGestureRecognizer(tapGesture)
        backgroundInst.userInteractionEnabled = true
        
        let skView = self.view as! SKView
        let myScene = GameScene(size: skView.frame.size)
        myScene.gamescene_delegate = self
        skView.presentScene(myScene)
        checkInstructionsLimit()
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        gameSceneView.paused = true
        return true
    }

    func checkInstructionsLimit() {
        if getInstructions()<2 {
            saveInstructions()
        } else {
            gameSceneView.paused = false
            backgroundInst.removeFromSuperview()
        }
    }
    
    func resetInstructions() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("instructions")
    }
    
    func saveInstructions() {
        NSUserDefaults.standardUserDefaults().setInteger(getInstructions()+1, forKey: "instructions")
    }
    
    func getInstructions() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("instructions")
    }
    
    func removeInst(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            backgroundInst.removeFromSuperview()
            backgroundInst = nil
            gameSceneView.paused = false
        }
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }

    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        bannerView.hidden = true
    }
    
    func gameOverDelegateFunc() {
        self.performSegueWithIdentifier("showGameOver", sender: nil)
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
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}