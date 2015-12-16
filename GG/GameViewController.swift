import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = true;
        skView.showsNodeCount = true;
        
        // then present the actual scene once the user clicks play
        let gameOverScene = GameOverScene(size: skView.frame.size, won: false)
        skView.presentScene(gameOverScene)
        
        // if user clicks play, then change scene
        let myScene = GameScene(size: skView.frame.size)
        skView.presentScene(myScene)
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
