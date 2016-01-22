import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = 0xFFFFFFFF
    static let Bird: UInt32 = 0b001
    static let Projectile: UInt32 = 0b010
    static let Granny: UInt32 = 0b011
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
    var background = SKSpriteNode(imageNamed: "bg");
    var viewController: GameViewController!
    
    var timerLevels = NSTimer();
    var countDownTimer = NSTimer();
    
    var countDownLabel = SKLabelNode(fontNamed:"Tahoma");
    var scoreTotalLbl = SKLabelNode(fontNamed:"Tahoma");
    var countDownDone: Bool = false;
    var counter: Int = 3;
    var lastBirdAdded : NSTimeInterval = 0.0;
    let backgroundVelocity : CGFloat = 3.0;
    let birdVelocity : CGFloat = 5.0;
    
    var granny = RTAMGranny(size: CGSize(width: 125, height: 125));
    let birdManager = RTAMBirdManager();
    let balloonManager = RTAMBalloonManager();
    var score: Int = 0;
    var numberOfGrannyHitsLeft = 4;
    
    var isRpgSelected = false;
    var hasRpgBeenShot = false;
    var numberOfBalloonsLeft = 4;
    var numberOfRpgShotsLeft = 10;
    
    var grannyWithoutMuzzles  = ["granny-ak-0b-no-muzzle", "granny-ak-1b-no-muzzle", "granny-ak-2b-no-muzzle", "granny-ak-3b-no-muzzle"];
    var grannyWithMuzzles = ["granny-ak-0b-with-muzzle", "granny-ak-1b-with-muzzle", "granny-ak-2b-with-muzzle", "granny-ak-3b-with-muzzle"];
    var grannyImageNoMuzzle = "granny-ak-4b-no-muzzle";
    var grannyImageWithMuzzle = "granny-ak-4b-with-muzzle";
    var grannyWithoutBackfires  = ["granny-rpg-0b-no-backfire", "granny-rpg-1b-no-backfire", "granny-rpg-2b-no-backfire", "granny-rpg-3b-no-backfire"];
    var grannyWithBackfires = ["granny-rpg-0b-with-backfire", "granny-rpg-1b-with-backfire", "granny-rpg-2b-with-backfire", "granny-rpg-3b-with-backfire"];
    var grannyImageNoBackfire = "granny-rpg-4b-no-backfire";
    var grannyImageWithBackfire = "granny-rpg-4b-with-backfire";
    
    override func didMoveToView(view: SKView) {
        background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        background.size = self.frame.size
        self.scaleMode = SKSceneScaleMode.ResizeFill
        self.addChild(background)
        
        self.scoreTotalLbl.fontSize = 40;
        self.countDownLabel.fontSize = 65;
        self.scoreTotalLbl.name = "Button"
        self.scoreTotalLbl.position = CGPoint(x: self.frame.size.width - self.frame.size.width * 0.90, y: self.frame.size.height - self.frame.size.height * 0.90);
        self.scoreTotalLbl.text = String(self.score);
        self.scoreTotalLbl.hidden = true;
        self.addChild(self.scoreTotalLbl);
        
        // Position me at half way point of the height (not divide!!)
        granny.physicsBody = SKPhysicsBody(rectangleOfSize: granny.size);
        granny.physicsBody?.dynamic = true;
        granny.physicsBody?.categoryBitMask = PhysicsCategory.Granny;
        granny.physicsBody?.contactTestBitMask = PhysicsCategory.Bird;
        granny.physicsBody?.collisionBitMask = PhysicsCategory.None;
        granny.position = CGPointMake(125, view.frame.size.height/2);
        granny.zPosition = 1;
        addChild(granny)
        
        let oscillate = SKAction.oscillation(amplitude: 22, timePeriod: 2, midPoint: granny.position);
        granny.runAction(SKAction.repeatActionForever(oscillate));
        
        let useRpg = SKSpriteNode(texture: SKTexture(imageNamed: "bazooka"), size: CGSizeMake(75, 75))
        useRpg.position = CGPointMake(self.frame.size.width-self.frame.size.width*0.15, 20)
        useRpg.anchorPoint = CGPointMake(0,0)
        useRpg.name = "bazooka"
        self.addChild(useRpg)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        countDownLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        countDownLabel.text = String(counter)
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1.4, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        addChild(countDownLabel)
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self

        let seconds = 4.2
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            // When we have moved to this scene, let's start updating the score based on the timer
            self.scoreTotalLbl.hidden = false;
            self.timerLevels = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "updateBirdSpeedIncrementally", userInfo: nil, repeats: true)
        })
    }
    
    func updateScore() {
        self.score = self.score + 1
        scoreTotalLbl.text = String(self.score);
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
    
    func updateBirdSpeedIncrementally() {
        if (birdManager.durationOfFlight >= 10){
            birdManager.durationOfFlight = birdManager.durationOfFlight - 3
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
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
                    birdDidCollideWithGranny(firstNode, granny: secondNode)
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if countDownDone {
            // Choose one of the touches to work with
            guard let touch = touches.first else {
                return
            }
            
            let touchLocation = touch.locationInNode(self)
        
            // Set up initial location of projectile
            let projectile = RTAMBullet(size: CGSizeMake(15, 5))
            
            let grannyWithBackfire = SKTexture(imageNamed: self.grannyImageWithBackfire)
            let grannyNoBackfire = SKTexture(imageNamed: self.grannyImageNoBackfire)
            let grannyWithMuzzle = SKTexture(imageNamed: self.grannyImageWithMuzzle)
            let grannyNoMuzzle = SKTexture(imageNamed: self.grannyImageNoMuzzle)
            var grannyInUseNotShooting = SKTexture()
            var grannyInUseShooting = SKTexture()
            
            if ((self.nodeAtPoint(touchLocation).name == "bazooka") && (self.numberOfRpgShotsLeft > 0)) {
                isRpgSelected = true
                hasRpgBeenShot = false
                projectile.texture = SKTexture(imageNamed: "rocket")
                granny.texture = grannyNoBackfire
                grannyInUseShooting = grannyWithBackfire
                grannyInUseNotShooting = grannyNoBackfire
                
            } else if ((isRpgSelected == true) && (hasRpgBeenShot == false)) {
                projectile.texture = SKTexture(imageNamed: "rocket")
                
                let pause = SKAction.waitForDuration(0.5)
                let changeToAk = SKAction.runBlock {
                    self.granny.texture = grannyNoMuzzle
                }
                
                granny.runAction(SKAction.sequence([pause, changeToAk]))
                grannyInUseShooting = grannyWithMuzzle
                grannyInUseNotShooting = grannyNoMuzzle
                
                hasRpgBeenShot = true
                isRpgSelected = false
                self.numberOfRpgShotsLeft = self.numberOfRpgShotsLeft - 1
            } else {
                projectile.texture = SKTexture(imageNamed: "bullet")
                granny.texture = grannyNoMuzzle
                grannyInUseNotShooting = grannyNoMuzzle
                grannyInUseShooting = grannyWithMuzzle
                hasRpgBeenShot = true
            }
            
            projectile.position = CGPoint(x: granny.position.x + (granny.size.width * 0.44146), y: granny.position.y + (0.0163 * granny.size.height))
            projectile.position = CGPoint(x: granny.position.x + granny.size.width, y: granny.position.y+38)
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.dynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            
            let y = touchLocation.y - projectile.position.y
            let x = touchLocation.x - projectile.position.x
            let angle = atan2(y, x)
            
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
            
            self.granny.texture = grannyInUseShooting

            let wait = SKAction.waitForDuration(0.5)
            let run = SKAction.runBlock {
                self.granny.texture = grannyInUseNotShooting
            }
            granny.runAction(SKAction.sequence([wait, run]))
            
            // Create the actions
            let actionMove = SKAction.moveTo(realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            let projectileTilt = SKAction.rotateToAngle(angle, duration: 0.0)
            let grannyMove = SKAction.rotateToAngle(angle, duration: 0.5)
            let grannyMoveBack = SKAction.rotateToAngle(0, duration: 0.5)
            
            let projPos = SKAction.moveTo(granny.position, duration: 0.0)
            projectile.runAction(SKAction.sequence([ projectileTilt,projPos, actionMove, actionMoveDone]))
            
            granny.runAction(SKAction.sequence([grannyMove, grannyMoveBack]))
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func projectileDidCollideWithMonster(bird: SKSpriteNode, bullet: SKSpriteNode) {
        bullet.removeFromParent()
        
        let birdExplodeOne = SKTexture(imageNamed:"yellow-bird-explode-one")
        birdExplodeOne.filteringMode = SKTextureFilteringMode.Nearest
        
        let birdExplodeTwo = SKTexture(imageNamed:"yellow-bird-explode-two")
        birdExplodeTwo.filteringMode = SKTextureFilteringMode.Nearest
        
        let birdExplodeThree = SKTexture(imageNamed:"yellow-bird-explode-three")
        birdExplodeThree.filteringMode = SKTextureFilteringMode.Nearest
        
        let birdExplodeFour = SKTexture(imageNamed:"yellow-bird-explode-four")
        birdExplodeFour.filteringMode = SKTextureFilteringMode.Nearest
        
        let explode = SKAction.animateWithTextures([birdExplodeOne, birdExplodeTwo, birdExplodeThree, birdExplodeFour], timePerFrame:0.05);
        let removeBird = SKAction.removeFromParent()
        
        updateScore()
        bird.runAction(SKAction.sequence([explode, removeBird]))
    }
    
    func birdDidCollideWithGranny(bird: SKSpriteNode, granny: SKSpriteNode) {
        if numberOfGrannyHitsLeft > 0 {
            numberOfGrannyHitsLeft = numberOfGrannyHitsLeft - 1
            numberOfBalloonsLeft  = numberOfBalloonsLeft - 1
            grannyImageNoMuzzle = grannyWithoutMuzzles[numberOfBalloonsLeft]
            grannyImageWithMuzzle = grannyWithMuzzles[numberOfBalloonsLeft]
            grannyImageNoBackfire = grannyWithoutBackfires[numberOfBalloonsLeft]
            grannyImageWithBackfire = grannyWithBackfires[numberOfBalloonsLeft]
            
            if (isRpgSelected) {
                self.granny.texture = SKTexture(imageNamed: grannyImageNoBackfire)
            } else {
                self.granny.texture = SKTexture(imageNamed: grannyImageNoMuzzle)
            }
            
            bird.removeFromParent()
            
            if (numberOfGrannyHitsLeft) == 0 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let gameOverScene = GameOverScene(size: self.size)
                    let transition = SKTransition.flipVerticalWithDuration(2.0)
                    gameOverScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene!.view?.presentScene(gameOverScene, transition: transition)
                })
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if countDownDone {
            if currentTime - self.lastBirdAdded > 0.6 {
                self.lastBirdAdded = currentTime + 0.6
                
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