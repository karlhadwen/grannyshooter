import SpriteKit
import AVFoundation

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = 0xFFFFFFFF
    static let Bird: UInt32 = 0b001
    static let Projectile: UInt32 = 0b010
    static let Granny: UInt32 = 0b011
    static let littleDot: UInt32 = 0b111
}

let π = CGFloat(M_PI)

extension SKAction {
    static func oscillation(amplitude a: CGFloat, timePeriod t: Double, midPoint: CGPoint) -> SKAction {
        let action = SKAction.customActionWithDuration(t) { node, currentTime in
            let displacement = a * sin(2 * π * currentTime / CGFloat(t))
            node.position.y = midPoint.y + displacement
        }
        return action
    }
}

@objc protocol GameOverDelegate {
    func gameOverDelegateFunc()
}

class GameScene: SKScene, SKPhysicsContactDelegate  {
    var gamescene_delegate : GameOverDelegate?
    var viewController: GameViewController!
    var audioPlayerAK47: AVAudioPlayer?
    var audioPlayerRpg: AVAudioPlayer?
    var audioPlayerBirdPop: AVAudioPlayer?
    var shootingTimer: NSTimer!
    var background = SKSpriteNode(imageNamed: "bg");
    
    var timerLevels = NSTimer();
    var countDownTimer = NSTimer();
    var rpgTimer = NSTimer();
    
    let bulletPos = SKSpriteNode(imageNamed: "bullet-spot")
    var countDownLabel = SKLabelNode(fontNamed: "Bangers-Regular");
    var scoreTotalLbl = SKLabelNode(fontNamed: "Bangers-Regular");
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
    var numberOfRpgShotsLeft = 5;
    
    var grannyWithoutMuzzles  = ["granny-ak-0b-no-muzzle", "granny-ak-1b-no-muzzle", "granny-ak-2b-no-muzzle", "granny-ak-3b-no-muzzle"];
    var grannyWithMuzzles = ["granny-ak-0b-with-muzzle", "granny-ak-1b-with-muzzle", "granny-ak-2b-with-muzzle", "granny-ak-3b-with-muzzle"];
    var grannyImageNoMuzzle = "granny-ak-4b-no-muzzle";
    var grannyImageWithMuzzle = "granny-ak-4b-with-muzzle";
    var grannyWithoutBackfires  = ["granny-rpg-0b-no-backfire", "granny-rpg-1b-no-backfire", "granny-rpg-2b-no-backfire", "granny-rpg-3b-no-backfire"];
    var grannyWithBackfires = ["granny-rpg-0b-with-backfire", "granny-rpg-1b-with-backfire", "granny-rpg-2b-with-backfire", "granny-rpg-3b-with-backfire"];
    var grannyImageNoBackfire = "granny-rpg-4b-no-backfire";
    var grannyImageWithBackfire = "granny-rpg-4b-with-backfire";
    
    let useRpg = SKSpriteNode(texture: SKTexture(imageNamed: "bazooka"), size: CGSizeMake(75, 75))
    
    override func didMoveToView(view: SKView) {
        if let playAK47 = self.setupAudioPlayerWithFile("ak47", type: "mp3") {
            self.audioPlayerAK47 = playAK47
        }
        if let playRpg = self.setupAudioPlayerWithFile("rpg", type: "mp3") {
            self.audioPlayerRpg = playRpg
        }
        
        self.background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.background.size = self.frame.size
        self.scaleMode = SKSceneScaleMode.ResizeFill
        self.addChild(self.background)
        
        self.granny.physicsBody = SKPhysicsBody(rectangleOfSize: self.granny.size);
        self.granny.physicsBody?.dynamic = true;
        self.granny.physicsBody?.categoryBitMask = PhysicsCategory.Granny;
        self.granny.physicsBody?.contactTestBitMask = PhysicsCategory.Bird;
        self.granny.physicsBody?.collisionBitMask = PhysicsCategory.None;
        self.granny.position = CGPointMake(125, view.frame.size.height/2);
        self.granny.zPosition = 1;
        self.addChild(self.granny)
        
        self.bulletPos.physicsBody = SKPhysicsBody(rectangleOfSize: self.bulletPos.size);
        self.bulletPos.physicsBody?.dynamic = true;
        self.bulletPos.physicsBody?.categoryBitMask = PhysicsCategory.littleDot;
        self.bulletPos.physicsBody?.contactTestBitMask = PhysicsCategory.None;
        self.bulletPos.physicsBody?.collisionBitMask = PhysicsCategory.None;
        self.bulletPos.position = CGPoint(x: self.granny.position.x + (self.granny.size.width * 0.44146), y: self.granny.position.y + (0.0163 * self.granny.size.height))
        self.addChild(self.bulletPos)
        
        let joint = SKPhysicsJointFixed.jointWithBodyA(self.granny.physicsBody!, bodyB: self.bulletPos.physicsBody!, anchor: self.granny.anchorPoint)
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.addJoint(joint)
        
        let oscillate = SKAction.oscillation(amplitude: 22, timePeriod: 2, midPoint: self.granny.position);
        self.granny.runAction(SKAction.repeatActionForever(oscillate));
        
        self.scoreTotalLbl.fontSize = 40;
        self.countDownLabel.fontSize = 65;
        self.scoreTotalLbl.name = "Button"
        self.scoreTotalLbl.position = CGPoint(x: self.frame.size.width - self.frame.size.width * 0.90, y: self.frame.size.height - self.frame.size.height * 0.92);
        self.scoreTotalLbl.text = String(self.score);
        self.scoreTotalLbl.hidden = true;
        self.addChild(self.scoreTotalLbl);
        
        self.useRpg.position = CGPointMake(self.frame.size.width-self.frame.size.width*0.15, 20)
        self.useRpg.anchorPoint = CGPointMake(0,0)
        self.useRpg.name = "bazooka"
        self.useRpg.zPosition = 10
        self.addChild(self.useRpg)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        self.scoreTotalLbl.hidden = true;
        let seconds = 4.2
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        self.countDownLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
        self.countDownLabel.text = String(self.counter)
        self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
        self.addChild(self.countDownLabel)
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
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

    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer? {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var audioPlayer: AVAudioPlayer?
        
        if path != nil {
            do {
                try audioPlayer = AVAudioPlayer(contentsOfURL: url)
            } catch {
                print("Player not available")
            }
        }
        
        return audioPlayer
    }
    
    func playShootingSoundAK47() {
        audioPlayerAK47?.play()
    }
    
    func playShootingSoundRpg() {
        audioPlayerRpg?.play()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if countDownDone {
            // Choose one of the touches to work with
            guard let touch = touches.first else {
                return
            }
            
            let touchLocation = touch.locationInNode(self)
        
            // Set up initial location of projectile
            let projectile = RTAMBullet(size: CGSizeMake(13, 5))
            
            let grannyWithBackfire = SKTexture(imageNamed: self.grannyImageWithBackfire)
            let grannyNoBackfire = SKTexture(imageNamed: self.grannyImageNoBackfire)
            let grannyWithMuzzle = SKTexture(imageNamed: self.grannyImageWithMuzzle)
            let grannyNoMuzzle = SKTexture(imageNamed: self.grannyImageNoMuzzle)
            var grannyInUseNotShooting = SKTexture()
            var grannyInUseShooting = SKTexture()
            
            if ((self.nodeAtPoint(touchLocation).name == "bazooka") && (self.numberOfRpgShotsLeft > 0) && (isRpgSelected == false) && useRpg.alpha == 1) {
                isRpgSelected = true
                hasRpgBeenShot = false
                projectile.texture = SKTexture(imageNamed: "rocket")
                granny.texture = grannyNoBackfire
                grannyInUseShooting = grannyWithBackfire
                grannyInUseNotShooting = grannyNoBackfire
                useRpg.alpha = 0.5
                return
            } else if ((isRpgSelected == true) && (hasRpgBeenShot == false)) {
                projectile.texture = SKTexture(imageNamed: "rocket")
                projectile.name = "rocket"
                
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
                let waitForAlpha = SKAction.waitForDuration(8)
                let changeAlphaBack = SKAction.runBlock{self.useRpg.alpha = 1}
                useRpg.runAction(SKAction.sequence([waitForAlpha, changeAlphaBack]))
                shootingTimer = NSTimer.scheduledTimerWithTimeInterval(0.19, target: self, selector: Selector("playShootingSoundRpg"), userInfo: nil, repeats: false)
            } else {
                projectile.texture = SKTexture(imageNamed: "bullet")
                projectile.name = "bullet"
                granny.texture = grannyNoMuzzle
                grannyInUseNotShooting = grannyNoMuzzle
                grannyInUseShooting = grannyWithMuzzle
                hasRpgBeenShot = true
                shootingTimer = NSTimer.scheduledTimerWithTimeInterval(0.19, target: self, selector: Selector("playShootingSoundAK47"), userInfo: nil, repeats: false)
            }
            
            projectile.position = bulletPos.position
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
            let shootAmount = direction * 800
            
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
            projectile.runAction(SKAction.sequence([projectileTilt, projPos, actionMove, actionMoveDone]))
            
            granny.runAction(SKAction.sequence([grannyMove, grannyMoveBack]))
            projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func projectileDidCollideWithMonster(bird: SKSpriteNode, bullet: SKSpriteNode) {
        if (bullet.name == "rocket") {
            for (var i = 0; i < birdManager.birds.count ; i++) {
                let birdInLoop = birdManager.birds[i]
                var explodeImage = ""
                
                if (birdInLoop?.name == "top-bird") {
                    explodeImage = "green-bird-explode-last"
                } else if (birdInLoop?.name == "straight-bird") {
                    explodeImage = "yellow-bird-explode-last"
                } else if (birdInLoop?.name == "bottom-bird") {
                    explodeImage = "yellow-bird-explode-last"
                }
                
                let birdExplode = SKTexture(imageNamed: explodeImage)
                birdExplode.filteringMode = SKTextureFilteringMode.Nearest
                
                let explode = SKAction.animateWithTextures([birdExplode], timePerFrame: 0.1);
                let removeBird = SKAction.removeFromParent()
                
                birdInLoop?.runAction(SKAction.sequence([explode, removeBird]))
            }
        } else {
            var explodeImage = ""
            
            if (bird.name == "top-bird") {
                explodeImage = "green-bird-explode-last"
            } else if (bird.name == "straight-bird") {
                explodeImage = "yellow-bird-explode-last"
            } else if (bird.name == "bottom-bird") {
                explodeImage = "yellow-bird-explode-last"
            }
            
            let birdExplode = SKTexture(imageNamed: explodeImage)
            birdExplode.filteringMode = SKTextureFilteringMode.Nearest
            
            let explode = SKAction.animateWithTextures([birdExplode], timePerFrame: 0.1);
            let removeBird = SKAction.removeFromParent()
            
            bird.runAction(SKAction.sequence([explode, removeBird]))
        }
        
        bullet.removeFromParent()
        updateScore()
    }
    
    func birdDidCollideWithGranny(bird: SKSpriteNode, granny: SKSpriteNode) {
        if self.numberOfGrannyHitsLeft > 0 {
            self.numberOfGrannyHitsLeft = self.numberOfGrannyHitsLeft - 1
            self.numberOfBalloonsLeft  = self.numberOfBalloonsLeft - 1
            self.grannyImageNoMuzzle = self.grannyWithoutMuzzles[self.numberOfBalloonsLeft]
            self.grannyImageWithMuzzle = self.grannyWithMuzzles[self.numberOfBalloonsLeft]
            self.grannyImageNoBackfire = self.grannyWithoutBackfires[self.numberOfBalloonsLeft]
            self.grannyImageWithBackfire = self.grannyWithBackfires[self.numberOfBalloonsLeft]
            
            if (self.isRpgSelected) {
                self.granny.texture = SKTexture(imageNamed: self.grannyImageNoBackfire)
            } else {
                self.granny.texture = SKTexture(imageNamed: self.grannyImageNoMuzzle)
            }
            
            bird.removeFromParent()
            
            if (self.numberOfGrannyHitsLeft) == 0 {
                gamescene_delegate?.gameOverDelegateFunc()
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if self.countDownDone {
            if currentTime - self.lastBirdAdded > 0.6 {
                self.lastBirdAdded = currentTime + 0.6
                
                let bird = self.birdManager.addBird(self)!
                self.addChild(bird)
                
                let topBird = self.birdManager.addBirdFromTop(self)!
                self.addChild(topBird)
                
                let bottomBird = self.birdManager.addBirdFromBottom(self)!
                self.addChild(bottomBird)
            }
        }
    }
}