//
//  GameScene.swift
//  GG
//
//  Created by Karl Hadwen on 17/11/2015.
//  Copyright (c) 2015 Karl Hadwen. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Bird  : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let Gun: UInt32 = 0b11
}

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

class GameScene: SKScene, SKPhysicsContactDelegate  {
    var lastBirdAdded : NSTimeInterval = 0.0
    let backgroundVelocity : CGFloat = 3.0
    let birdVelocity : CGFloat = 5.0
    let gun = RTAMGun(size: CGSize(width: 50, height: 50))
    let balloon = RTAMBalloon(size: CGSize(width: 30, height: 30))
    let balloon2 = RTAMBalloon(size: CGSize(width: 30, height: 30))
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor(red:56/255, green: 206/255, blue: 249/255, alpha:1)
        
        // position me at half way point of the height (not divide!!)
        gun.physicsBody = SKPhysicsBody(rectangleOfSize: gun.size)
        gun.physicsBody?.dynamic = true
        gun.physicsBody?.categoryBitMask = PhysicsCategory.Gun
        gun.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        gun.physicsBody?.collisionBitMask = PhysicsCategory.None
        gun.position = CGPointMake(60, view.frame.size.height/2)
        
        // half way point and add 10+
        
        // we set the position, and then we set the anchor point of that particular position
        // so if we place in 20/30 position (x,y), the anchor is saying what part of the 20/30 position
        // so if we place in 0.5,0, that's -> onwards, or if 0,0, that's bottom left.
        balloon.position = CGPointMake(70, view.frame.size.height/2 + 25)
        balloon.anchorPoint = CGPointMake(0.5, 0)
        
        balloon2.position = CGPointMake(90, view.frame.size.height/2 + 25)
        balloon2.anchorPoint = CGPointMake(0.5, 0)
        
        addChild(gun)
        addChild(balloon)
        addChild(balloon2)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        self.addBird()
        self.addBirdfromTop()
        self.addBirdfromBottom()
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addBird() {
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
        let random : CGFloat = CGFloat(arc4random_uniform(UInt32(self.frame.size.height - bird.size.height)))
        bird.position = CGPointMake(self.frame.size.width + 20, random)
        
        self.addChild(bird)
        
        // 3 - Determine offset of location to projectile
        let offset = gun.position - bird.position
        
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + bird.position
        
        
        // 9 - Create the actions
//        let actionMove = SKAction.moveTo(realDest, duration: 6.0)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, bird.position.x, bird.position.y)
        if(bird.position.y >= self.frame.height/2){
            CGPathAddCurveToPoint(path, nil, bird.position.x - 200, 100 , gun.position.x, gun.position.y, realDest.x, realDest.y)
        }
        else{
            CGPathAddCurveToPoint(path, nil, bird.position.x - 200, 250 , gun.position.x, gun.position.y, realDest.x, realDest.y)
        }
        
        let actionMove = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 2.0)
        
//        let circularPath = UIBezierPath(roundedRect: CGRectMake(0, 0, 100, 100), cornerRadius: 100)
//        let actionMove3 = SKAction.followPath(circularPath.CGPath, asOffset: false, orientToPath: false, duration: 6.0)
//        

        
        let actionMoveDone = SKAction.removeFromParent()
        bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addBirdfromTop() {
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
        let random : CGFloat = CGFloat(arc4random_uniform(UInt32(self.frame.size.width - self.frame.size.width/1.8)) + UInt32(self.frame.size.width/1.5))
        
        bird.position = CGPointMake(random, self.frame.size.height)
        self.addChild(bird)
        
        // 3 - Determine offset of location to projectile
        let offset = gun.position - bird.position
        
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + bird.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 5.0)
        let actionMoveDone = SKAction.removeFromParent()
        bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))

    }
    
    func addBirdfromBottom() {
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
        let random : CGFloat = CGFloat(arc4random_uniform(UInt32(self.frame.size.width - self.frame.size.width/1.8)) + UInt32(self.frame.size.width/1.5))
        bird.position = CGPointMake(random, 0)
        self.addChild(bird)
        
        // 3 - Determine offset of location to projectile
        let offset = gun.position - bird.position
        
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + bird.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 5.0)
        let actionMoveDone = SKAction.removeFromParent()
        bird.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }


    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        
        
        if ((firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b10) ||
            (secondBody.categoryBitMask == 0b1 && firstBody.categoryBitMask == 0b10)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, bird: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b11) ||
            (secondBody.categoryBitMask == 0b1 && firstBody.categoryBitMask == 0b11)){
                birdDidCollideWithGranny(firstBody.node as! SKSpriteNode, gun: secondBody.node as! SKSpriteNode)
        }
        
        
    }

    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = RTAMBullet(size: CGSizeMake(5, 5))
        projectile.position = CGPoint(x: gun.position.x+gun.size.width, y: gun.position.y)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func moveObstacle() {
        self.enumerateChildNodesWithName("normal-bird", usingBlock: { (node, stop) -> Void in
            if let obstacle = node as? SKSpriteNode {
                obstacle.position = CGPoint(x: obstacle.position.x - self.birdVelocity, y: obstacle.position.y)
                if obstacle.position.x < 0 {
                    obstacle.removeFromParent()
                }
            }
        })
        
    }
    
    func projectileDidCollideWithMonster(bullet:SKSpriteNode, bird:SKSpriteNode) {
        print("Hit")
        bullet.removeFromParent()
        bird.removeFromParent()
    }
    
    func birdDidCollideWithGranny(bird:SKSpriteNode, gun:SKSpriteNode) {
        print("Hit Granny")
       // balloon.removeFromParent()
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if currentTime - self.lastBirdAdded > 0.3 {
            self.lastBirdAdded = currentTime + 0.3
            self.addBird()
            self.addBirdfromTop()
            self.addBirdfromBottom()
        }
        
       // self.moveObstacle()
    }
}
