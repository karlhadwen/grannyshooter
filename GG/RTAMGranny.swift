import Foundation
import SpriteKit

class RTAMGranny: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "granny-ak47-no-muzzle"), color: UIColor.blackColor(), size: CGSizeMake(size.width, size.height))
        self.physicsBody = SKPhysicsBody(circleOfRadius: (self.size.width/2) / 1.4)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Granny
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        anchorPoint = CGPointMake(0.5, 0.5)
    }
}