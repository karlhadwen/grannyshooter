import Foundation
import SpriteKit

class RTAMGranny: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "granny"), color: UIColor.blackColor(), size: CGSizeMake(size.width, size.height))
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Granny
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        self.physicsBody?.collisionBitMask = PhysicsCategory.None

        anchorPoint = CGPointMake(0, 0.5)
    }
    
    func addGranny() {
        // Initializing granny node
        mainInstance.granny = SKSpriteNode(imageNamed: "granny")
        mainInstance.granny.setScale(0.5)
        mainInstance.granny.zRotation = CGFloat(-M_PI/2)
        
        mainInstance.granny = RTAMGranny(size: CGSizeMake(85, 85))
        
        // Adding SpriteKit physics body for collision detection
        mainInstance.granny.physicsBody = SKPhysicsBody(rectangleOfSize: mainInstance.granny.size)
        mainInstance.granny.physicsBody?.categoryBitMask = UInt32(mainInstance.grannyCategory)
        mainInstance.granny.physicsBody?.dynamic = true
        mainInstance.granny.physicsBody?.contactTestBitMask = UInt32(mainInstance.obstacleCategory)
        mainInstance.granny.physicsBody?.collisionBitMask = 0
        mainInstance.granny.name = "Granny"
        mainInstance.granny.position = CGPointMake(0.0+80, self.size.height - 100)
        mainInstance.granny.anchorPoint = CGPointMake(0.5, 0.5)
        
        self.addChild(mainInstance.granny)
        
        mainInstance.actionMoveUp = SKAction.moveByX(0, y: 80, duration: 0.1)
        mainInstance.actionMoveDown = SKAction.moveByX(0, y: -80, duration: 0.1)
    }
}