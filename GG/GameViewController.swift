import UIKit
import SpriteKit

class GameViewController: UIViewController, GameOverDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = self.view as! SKView
        let myScene = GameScene(size: skView.frame.size)
        myScene.gamescene_delegate = self
        skView.presentScene(myScene)
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