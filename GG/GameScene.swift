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
    
    private var granny: RTAMGranny!
    
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
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
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
        let random : CGFloat = CGFloat(arc4random_uniform(567))
        bird.position = CGPointMake(self.frame.size.width + 20, random)
        
        if (bird.position.y > 0 && bird.position.y+bird.size.height < self.frame.size.height) {
            self.addChild(bird)
        } else {
            bird.removeFromParent()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        firstBody = contact.bodyA
        secondBody = contact.bodyB
        
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//         
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//           
//        }
        
        
        if ((firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b10) ||
            (secondBody.categoryBitMask == 0b1 && firstBody.categoryBitMask == 0b10)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, bird: secondBody.node as! SKSpriteNode)
        }
        else if ((firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b11) ||
            (secondBody.categoryBitMask == 0b1 && firstBody.categoryBitMask == 0b11)){
            birdDidCollideWithGranny(firstBody.node as! SKSpriteNode, gun: secondBody.node as! SKSpriteNode)
        }
        
    }

    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        /* Called when a touch begins */
//        for touch: AnyObject in touches {
//            let location = touch.locationInNode(self)
//            let screenSize = UIScreen.mainScreen().bounds.size
//            let screenWidth = screenSize.width
//            let screenHeight = screenSize.height
//            
//            if location.y > mainInstance.granny.position.y {
//                // change these static positions
//                if mainInstance.granny.position.y < 567 {
//                    mainInstance.granny.runAction(mainInstance.actionMoveUp)
//                }
//            } else {
//                // change these static positions
//                if mainInstance.granny.position.y > 100 {
//                    mainInstance.granny.runAction(mainInstance.actionMoveDown)
//                }
//            }
//            
//            let bulletFinalLocation = touch.locationInNode(self)
//            let move = SKAction.moveTo(bulletFinalLocation, duration: 4.0)
//            let theBullet = self.nodeAtPoint(CGPointMake(21, frame.size.height/2))
//            theBullet.runAction(move)
//            let bullet = RTAMBullet(size: CGSizeMake(2, 2))
//            bullet.position = CGPointMake(21, frame.size.height/2)
//            addChild(bullet)
//        }
//    }
    
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
        balloon.removeFromParent()
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if currentTime - self.lastBirdAdded > 0.1 {
            self.lastBirdAdded = currentTime + 0.1
            self.addBird()
        }
        
        self.moveObstacle()
    }
}
