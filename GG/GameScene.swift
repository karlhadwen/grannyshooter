import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = 0xFFFFFFFF
    static let Bird: UInt32 = 0b001
    static let Projectile: UInt32 = 0b010
    static let Gun: UInt32 = 0b011
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
    var timer = NSTimer();
    var countDownTimer = NSTimer();
    var countDownLabel = SKLabelNode(fontNamed:"Tahoma");
    var scoreTotalLbl = SKLabelNode(fontNamed:"Tahoma");
    var countDownDone: Bool = false;
    var counter: Int = 3;
    var lastBirdAdded : NSTimeInterval = 0.0;
    let backgroundVelocity : CGFloat = 3.0;
    let birdVelocity : CGFloat = 5.0;
    let gun = RTAMGun(size: CGSize(width: 80, height: 50));
    let birdManager = RTAMBirdManager();
    let balloonManager = RTAMBalloonManager();
    var score: Int = 0;

    override func didMoveToView(view: SKView) {
        //TODO: Let's clean this up and create a file for GUI elements
        self.scoreTotalLbl.fontSize = 40;
        self.countDownLabel.fontSize = 65;
        self.scoreTotalLbl.name = "Button"
        self.scoreTotalLbl.position = CGPoint(x: 75, y: 30);
        self.scoreTotalLbl.text = String(self.score);
        self.scoreTotalLbl.hidden = true;
        self.addChild(self.scoreTotalLbl);
        self.backgroundColor = UIColor(red:56/255, green: 206/255, blue: 249/255, alpha:1);
        
        // Position me at half way point of the height (not divide!!)
        gun.physicsBody = SKPhysicsBody(rectangleOfSize: gun.size);
        gun.physicsBody?.dynamic = true;
        gun.physicsBody?.categoryBitMask = PhysicsCategory.Gun;
        gun.physicsBody?.contactTestBitMask = PhysicsCategory.Bird;
        gun.physicsBody?.collisionBitMask = PhysicsCategory.None;
        gun.position = CGPointMake(60, view.frame.size.height/2);
        addChild(gun)
        
        let oscillate = SKAction.oscillation(amplitude: 22, timePeriod: 2, midPoint: gun.position);
        gun.runAction(SKAction.repeatActionForever(oscillate));
        
        let balloon1 = balloonManager.addBalloon(gun, index: 0)!
        let balloon2 = balloonManager.addBalloon(gun, index: 1)!
        let balloon3 = balloonManager.addBalloon(gun, index: 2)!
        let balloon4 = balloonManager.addBalloon(gun, index: 3)!
 
        addChild(balloon1);
        addChild(balloon2);
        addChild(balloon3);
        addChild(balloon4);
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        countDownLabel.position = CGPointMake( self.frame.size.width/2, self.frame.size.height/2)
        countDownLabel.text = String(counter)
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        addChild(countDownLabel)
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self

        let seconds = 3.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            // When we have moved to this scene, let's start updating the score based on the timer
            self.scoreTotalLbl.hidden = false;
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateScoreIncrementally", userInfo: nil, repeats: true)
        })
    }

    func updateCounter() {
        counter = counter - 1
        countDownLabel.text = String(counter)
        
        if (counter == 0) {
            countDownTimer.invalidate()
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
    
    func updateScoreIncrementally() {
        self.score = self.score + 1
        scoreTotalLbl.text = String(self.score);
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        self.score = self.score + 5
        scoreTotalLbl.text = String(self.score);

        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b10) {
            if let firstNode = firstBody.node as? SKSpriteNode,
                let secondNode = secondBody.node as? SKSpriteNode {
                    projectileDidCollideWithMonster(firstNode, bullet: secondNode)
            }
        } else if (firstBody.categoryBitMask == 0b1 && secondBody.categoryBitMask == 0b11) {
            if let firstNode = firstBody.node as? SKSpriteNode,
                let secondNode = secondBody.node as? SKSpriteNode {
                    birdDidCollideWithGranny(firstNode, gun: secondNode)
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.locationInNode(self)
        
        // Set up initial location of projectile
        let projectile = RTAMBullet(size: CGSizeMake(5, 5))
        projectile.position = CGPoint(x: gun.position.x + gun.size.width, y: gun.position.y)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // OK to add now - you've double checked position
        addChild(projectile)
        
        // Get the direction of where to shoot
        let direction = offset.normalized()
        
        // Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster(bird:SKSpriteNode, bullet:SKSpriteNode) {
        bird.removeFromParent()
        bullet.removeFromParent()
    }
    
    func birdDidCollideWithGranny(bird: SKSpriteNode, gun: SKSpriteNode) {
        // Check if all ballons are gone, if they are, run this
        //let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        //let gameOverScene = GameOverScene(size: self.size, won: false)
        
        // Game over scene
        //TODO: Once all birds are gone, do this!
        //self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    override func update(currentTime: CFTimeInterval) {
        if countDownDone {
            if currentTime - self.lastBirdAdded > 0.3 {
                self.lastBirdAdded = currentTime + 0.3
                
                let bird = birdManager.addBird(self)!
                addChild(bird)
                
                let topBird = birdManager.addBirdFromBottom(self)!
                addChild(topBird)
                
                let bottomBird = birdManager.addBirdFromTop(self)!
                addChild(bottomBird)
            }
        }
    }
}