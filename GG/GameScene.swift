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
    static let All       : UInt32 = 0xFFFFFFFF
    static let Bird  : UInt32 = 0b001
    static let Projectile: UInt32 = 0b010
    static let Gun: UInt32 = 0b100
}


let π = CGFloat(M_PI)
extension SKAction {
    
    // amplitude  - the amount the height will vary by, set this to 200 in your case.
    // timePeriod - the time it takes for one complete cycle
    // midPoint   - the point around which the oscillation occurs.
    
    static func oscillation(amplitude a: CGFloat, timePeriod t: Double, midPoint: CGPoint) -> SKAction {
        let action = SKAction.customActionWithDuration(t) { node, currentTime in
            let displacement = a * sin(2 * π * currentTime / CGFloat(t))
            node.position.y = midPoint.y + displacement
        }
        
        return action
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    var countDownLabel = SKLabelNode(text: "3")
    var countDownDone: Bool = false
    var timer = NSTimer()
    var counter: Int = 3
    var lastBirdAdded : NSTimeInterval = 0.0
    let backgroundVelocity : CGFloat = 3.0
    let birdVelocity : CGFloat = 5.0
    let gun = RTAMGun(size: CGSize(width: 50, height: 50))
    let balloon = RTAMBalloon(size: CGSize(width: 30, height: 30))
    let balloon2 = RTAMBalloon(size: CGSize(width: 30, height: 30))
    
    
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor(red:56/255, green: 206/255, blue: 249/255, alpha:1)
      
      //  let birdManager = RTAMBirdManager(gameScene: self)
        
        // position me at half way point of the height (not divide!!)
        gun.physicsBody = SKPhysicsBody(rectangleOfSize: gun.size)
        gun.physicsBody?.dynamic = true
        gun.physicsBody?.categoryBitMask = PhysicsCategory.Gun
        gun.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        gun.physicsBody?.collisionBitMask = PhysicsCategory.None
        gun.position = CGPointMake(60, view.frame.size.height/2)
        addChild(gun)
        
        let oscillate = SKAction.oscillation(amplitude: 22,
            timePeriod: 2,
            midPoint: gun.position)
        gun.runAction(SKAction.repeatActionForever(oscillate))
        
        
        
        // half way point and add 10+
        
        // we set the position, and then we set the anchor point of that particular position
        // so if we place in 20/30 position (x,y), the anchor is saying what part of the 20/30 position
        // so if we place in 0.5,0, that's -> onwards, or if 0,0, that's bottom left.
        
        balloon.position = CGPointMake(70, gun.position.y + 25)
        balloon.anchorPoint = CGPointMake(0.5, 0)
        
        balloon2.position = CGPointMake(90, gun.position.y + 25)
        balloon2.anchorPoint = CGPointMake(0.5, 0)
        
        let oscillate2 = SKAction.oscillation(amplitude: 22,
            timePeriod: 2,
            midPoint: balloon.position)
        
        balloon.runAction(SKAction.repeatActionForever(oscillate2))
        
        balloon2.runAction(SKAction.repeatActionForever(oscillate2))
        
        addChild(balloon)
        addChild(balloon2)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        countDownLabel.position = CGPointMake( self.frame.size.width/2, self.frame.size.height/2)
        countDownLabel.text = String(counter)
        countDownLabel.fontColor = UIColor(CGColor: UIColor.blackColor().CGColor)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        
        addChild(countDownLabel)
        
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        
    }
    
    func updateCounter() {
        counter = counter - 1
        countDownLabel.text = String(counter)
        if(counter == 0){
            timer.invalidate()
            countDownLabel.removeFromParent()
            countDownDone = true
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
//        var firstBody = SKPhysicsBody()
//        var secondBody = SKPhysicsBody()
//        
//        
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            firstBody = contact.bodyA
//            secondBody = contact.bodyB
//        } else {
//            firstBody = contact.bodyB
//            secondBody = contact.bodyA
//        }
//
//        
//        if (firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b10) {
//            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, bullet: secondBody.node as! SKSpriteNode)
//        }
//        else if (firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b11) {
//                birdDidCollideWithGranny(firstBody.node as! SKSpriteNode, gun: secondBody.node as! SKSpriteNode)
//        }
     
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
            
        case PhysicsCategory.Bird | PhysicsCategory.Projectile:
            
            
            if contact.bodyA.categoryBitMask == PhysicsCategory.Bird {
                projectileDidCollideWithMonster( contact.bodyA.node as! SKSpriteNode, bullet: contact.bodyB.node as! SKSpriteNode)
            } else {
                projectileDidCollideWithMonster( contact.bodyB.node as! SKSpriteNode, bullet: contact.bodyA.node as! SKSpriteNode)

            }
            
        case PhysicsCategory.Bird | PhysicsCategory.Gun:
            
            if contact.bodyA.categoryBitMask == PhysicsCategory.Bird {
                print("Bird hit granny")
            } else {
                print("Bird hit granny")
            }
           
        default:
            
            // Nobody expects this, so satisfy the compiler and catch
            // ourselves if we do something we didn't plan to
            fatalError("other collision: \(contactMask)")
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
        projectile.position = CGPoint(x: gun.position.x + gun.size.width, y: gun.position.y)
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
    
    func projectileDidCollideWithMonster(bird:SKSpriteNode, bullet:SKSpriteNode) {
        print("Hit")
        bird.removeFromParent()
        bullet.removeFromParent()
        
    }
    
    func birdDidCollideWithGranny(bird: SKSpriteNode, gun: SKSpriteNode) {
        print("Hit Granny")
        // balloon.removeFromParent()
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if countDownDone {
            
            if  currentTime - self.lastBirdAdded > 0.3 {
                self.lastBirdAdded = currentTime + 0.3
                let birdManager = RTAMBirdManager(gameScene: self)
                let bird = birdManager.addBird()!
                addChild(bird)
                let topBird = birdManager.addBirdFromBottom()!
                addChild(topBird)
                let bottomBird = birdManager.addBirdFromTop()!
                addChild(bottomBird)
                
                
            }
        }
        
    }
}
