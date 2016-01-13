import Foundation
import SpriteKit
import UIKit

class RTAMBalloonManager {
    var occupiedPositions = [Int?](count: 4, repeatedValue: nil)
    // let birdInputLocations: [CGPoint] = [CGPoint(x: 10, y: 20), CGPoint(x: 30, y: 40), CGPoint(x: 50, y: 60)]

    init() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBalloon(node: SKSpriteNode, index: Int) -> SKSpriteNode? {
        let balloon = RTAMBalloon(size: CGSize(width: 30, height: 30))
        balloon.anchorPoint = CGPointMake(0.5, 0)
        
        if index == 0 {
            balloon.position = CGPointMake(node.position.x + 10, node.position.y + 25)
        }
        
        if (index == 1) {
            balloon.position = CGPointMake(node.position.x + 30, node.position.y + 25)
        }
        
        if (index == 2) {
            balloon.position = CGPointMake(node.position.x + 50, node.position.y + 25)
        }
        
        if (index == 3) {
            balloon.position = CGPointMake(node.position.x + 70, node.position.y + 25)
        }
        
        balloon.name = String(index)
        
        let oscillate2 = SKAction.oscillation(amplitude: 22, timePeriod: 2, midPoint: balloon.position)
        balloon.runAction(SKAction.repeatActionForever(oscillate2))
        
        self.occupiedPositions[index] = index
        
        return balloon
    }
    
    func removeBalloon(index: Int) {
        self.occupiedPositions[index] = nil
    }
}

