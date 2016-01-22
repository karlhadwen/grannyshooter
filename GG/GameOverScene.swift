import Foundation
import SpriteKit

class GameOverScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0.15, green:0.15, blue:0.3, alpha: 1.0)
        let startButton = SKSpriteNode(imageNamed: "start_button")
        startButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        startButton.name = "start_button"
        self.addChild(startButton)
    }
}