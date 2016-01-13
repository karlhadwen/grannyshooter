import Foundation
import SpriteKit
import UIKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class RTAMBirdManager {
    var birds = [SKSpriteNode?]()
    let birdInputLocations: [CGPoint] = [CGPoint(x: 10, y: 20), CGPoint(x: 30, y: 40), CGPoint(x: 50, y: 60)]
    var durationOfFlight = 30.0

    init() {}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBird(gameScene: SKScene) -> SKSpriteNode? {
        let bird = SKSpriteNode(imageNamed: "normal-bird")
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.size)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        bird.physicsBody?.collisionBitMask = PhysicsCategory.None
        bird.setScale(0.04)
        bird.anchorPoint = CGPointMake(0.5, 0)
        bird.name = "normal-bird"
        
        // Selecting random y position for bird
        let random : CGFloat = CGFloat(arc4random_uniform(UInt32(gameScene.size.height - bird.size.height)))
    
        bird.position = CGPointMake(gameScene.size.width + 20, random)
    
        let moveTo = CGPointMake(60, gameScene.size.height/2)
        
        // Determine offset of location to projectile
        let offset = moveTo - bird.position
        
        // Get the direction of where to shoot
        let direction = offset.normalized()
        
        // Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // Add the shoot amount to the current position
        let realDest = shootAmount + bird.position

        // Create the actions
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, bird.position.x, bird.position.y)
        
        if (bird.position.y >= gameScene.size.height/2) {
            CGPathAddCurveToPoint(path, nil, bird.position.x - 200, 100 , moveTo.x, moveTo.y, realDest.x, realDest.y)
        } else {
            CGPathAddCurveToPoint(path, nil, bird.position.x - 200, 250 , moveTo.x, moveTo.y, realDest.x, realDest.y)
        }
        
        let actionMove = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: durationOfFlight)
        let actionMoveDone = SKAction.removeFromParent()
        bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))

        self.birds.append(bird)
        
        return bird
    }
    
    func addBirdFromTop(gameScene: SKScene) -> SKSpriteNode? {
        let bird = SKSpriteNode(imageNamed: "normal-bird")
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.size)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        bird.physicsBody?.collisionBitMask = PhysicsCategory.None
        bird.setScale(0.04)
        bird.anchorPoint = CGPointMake(0.5, 0)
        bird.name = "top-bird"
        
        // Selecting random y position for bird
        let random : CGFloat = CGFloat(arc4random_uniform(UInt32(gameScene.size.width - gameScene.size.width/1.8)) + UInt32(gameScene.size.width/1.5))
        bird.position = CGPointMake(random, gameScene.size.height)
        
        let moveTo = CGPointMake(60, gameScene.size.height/2)
        // Determine offset of location to projectile
        
        let offset = moveTo - bird.position
        
        // Get the direction of where to shoot
        let direction = offset.normalized()
        
        // Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // Add the shoot amount to the current position
        let realDest = shootAmount + bird.position
        
        // Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: durationOfFlight)
        let actionMoveDone = SKAction.removeFromParent()
        bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        self.birds.append(bird)

        return bird
    }
    
    func addBirdFromBottom(gameScene: SKScene) -> SKSpriteNode? {
        let bird = SKSpriteNode(imageNamed: "normal-bird")
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.size)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        bird.physicsBody?.collisionBitMask = PhysicsCategory.None
        bird.setScale(0.04)
        bird.anchorPoint = CGPointMake(0.5, 0)
        bird.name = "bottom-bird"
        
        // Selecting random y position for bird
        let random : CGFloat = CGFloat(arc4random_uniform(UInt32(gameScene.size.width - gameScene.size.width/1.8)) + UInt32(gameScene.size.width/1.5))
        bird.position = CGPointMake(random, 0)
        
        let moveTo = CGPointMake(60, gameScene.size.height/2)
        
        // Determine offset of location to projectile
        let offset = moveTo - bird.position
        
        // Get the direction of where to shoot
        let direction = offset.normalized()
        
        // Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // Add the shoot amount to the current position
        let realDest = shootAmount + bird.position
        
        // Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: durationOfFlight)
        let actionMoveDone = SKAction.removeFromParent()
        bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))

        self.birds.append(bird)
        
        return bird
    }

    func getSizeOfArray() -> Int {
        return self.birds.count;
    }
    
    func getBirdAtIndex(index: Int) -> SKSpriteNode? {
        if (index < self.birds.count && index >= 0) {
            return self.birds[index]
        } else {
            return nil;
        }
    }
    
    func randomiseBirdInputLocation() {
        
    }
    
    func removeBird(index: Int) {
        self.birds.removeAtIndex(index)
    }
}
