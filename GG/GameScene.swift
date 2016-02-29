import SpriteKit
import AVFoundation
import AudioToolbox

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = 0xFFFFFFFF
    static let Bird: UInt32 = 0b001
    static let Projectile: UInt32 = 0b010
    static let Granny: UInt32 = 0b011
    static let littleDot: UInt32 = 0b111
    static let Balloon: UInt32 = 0b100
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
    
    var grannyInUseShooting = SKTexture()
    var countDownLabel = SKLabelNode(fontNamed: "Bangers-Regular");
    var scoreTotalLbl = SKLabelNode(fontNamed: "Bangers-Regular");
    var countDownDone: Bool = false;
    var counter: Int = 3;
    var lastBirdAdded : NSTimeInterval = 0.0;
    let backgroundVelocity : CGFloat = 3.0;
    let birdVelocity : CGFloat = 5.0;
    
    var granny = RTAMGranny(size: CGSize(width: 115, height: 105));
    let birdManager = RTAMBirdManager();
    let balloonManager = RTAMBalloonManager();
    let bulletPos = SKSpriteNode(imageNamed: "bullet-spot")
    let balloons = SKSpriteNode(texture: SKTexture(imageNamed: "four-balloons"), size: CGSizeMake(45, 70))
    var score: Int = 0;
    var numberOfGrannyHitsLeft = 4;
    
    var isRpgSelected = false;
    var hasRpgBeenShot = true;
    var numberOfBalloonsLeft = 4;
    var numberOfRpgShotsLeft = 5;
    var gameOver = false
    
    var grannyImageNoMuzzle = "granny-ak47-no-muzzle";
    var grannyImageWithMuzzle = "granny-ak47-muzzle";
    var grannyImageNoBackfire = "granny-rpg-no-fire";
    var grannyImageWithBackfire = "granny-rpg-with-fire";
    var balloonImages = ["zero-balloons", "one-balloon", "two-balloons", "three-balloons"]
    var balloonImage = "four-balloons"

    let useRpg = SKSpriteNode(texture: SKTexture(imageNamed: "bazooka"), size: CGSizeMake(75, 75))
    
    override func didMoveToView(view: SKView) {
        self.view?.paused = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pauseGameScene"), name: "PauseGameScene", object: nil)
        
        if let playAK47 = self.setupAudioPlayerWithFile("ak47", type: "mp3") {
            self.audioPlayerAK47 = playAK47
        }
        if let playRpg = self.setupAudioPlayerWithFile("rpg", type: "mp3") {
            self.audioPlayerRpg = playRpg
        }
        
        self.background.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.background.size = self.frame.size
        self.background.name = "bg"
        self.scaleMode = SKSceneScaleMode.ResizeFill
        self.addChild(self.background)
        
        self.granny.physicsBody = SKPhysicsBody(rectangleOfSize: self.granny.size);
        self.granny.physicsBody?.dynamic = true;
        self.granny.physicsBody?.categoryBitMask = PhysicsCategory.Granny;
        self.granny.physicsBody?.contactTestBitMask = PhysicsCategory.Bird;
        self.granny.physicsBody?.collisionBitMask = PhysicsCategory.None;
        self.granny.position = CGPointMake(125, view.frame.size.height/2);
        self.granny.zPosition = 1;
        self.addChild(granny)
        
        self.bulletPos.physicsBody = SKPhysicsBody(rectangleOfSize: bulletPos.size);
        self.bulletPos.physicsBody?.dynamic = true;
        self.bulletPos.physicsBody?.categoryBitMask = PhysicsCategory.littleDot;
        self.bulletPos.physicsBody?.contactTestBitMask = PhysicsCategory.None;
        self.bulletPos.physicsBody?.collisionBitMask = PhysicsCategory.None;
        self.bulletPos.position = CGPoint(x: granny.position.x + (granny.size.width * (492/1100)), y: granny.position.y + ((242.5/1005) * granny.size.height))
        addChild(bulletPos)
        
        self.balloons.physicsBody = SKPhysicsBody(rectangleOfSize: balloons.size);
        self.balloons.physicsBody?.dynamic = true;
        self.balloons.physicsBody?.categoryBitMask = PhysicsCategory.Balloon;
        self.balloons.physicsBody?.contactTestBitMask = PhysicsCategory.Bird;
        self.balloons.physicsBody?.collisionBitMask = PhysicsCategory.None;
        self.balloons.position = CGPoint(x: granny.position.x - ((219/1100) * granny.size.width) , y: granny.position.y + ((235.5/1005) * granny.size.height))
        self.balloons.anchorPoint = CGPointMake(1, 0)
        addChild(balloons)

        let joint = SKPhysicsJointFixed.jointWithBodyA(granny.physicsBody!, bodyB: balloons.physicsBody!, anchor: granny.anchorPoint)
        let joint2 = SKPhysicsJointFixed.jointWithBodyA(granny.physicsBody!, bodyB: bulletPos.physicsBody!, anchor: granny.anchorPoint)
        
        let oscillate = SKAction.oscillation(amplitude: 22, timePeriod: 2, midPoint: self.granny.position);
        self.granny.runAction(SKAction.repeatActionForever(oscillate));

        self.scoreTotalLbl.fontSize = 40;
        self.countDownLabel.fontSize = 65;
        self.scoreTotalLbl.name = "Button"
        self.scoreTotalLbl.position = CGPoint(x: self.frame.size.width - self.frame.size.width * 0.90, y: self.frame.size.height - self.frame.size.height * 0.86);
        self.scoreTotalLbl.text = String(self.score);
        self.scoreTotalLbl.hidden = true
        self.addChild(self.scoreTotalLbl);
        
        self.useRpg.position = CGPointMake(self.frame.size.width-self.frame.size.width*0.15, 40)
        self.useRpg.anchorPoint = CGPointMake(0,0)
        self.useRpg.name = "bazooka"
        self.useRpg.zPosition = 1
        self.addChild(self.useRpg)
    
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        physicsWorld.addJoint(joint)
        physicsWorld.addJoint(joint2)
        
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
            self.timerLevels = NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: "updateBirdSpeedIncrementally", userInfo: nil, repeats: true)
        })
    }
    
    func pauseGameScene() {
        self.view?.paused = true
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
        if (birdManager.durationOfFlight >= 9) {
            birdManager.durationOfFlight = birdManager.durationOfFlight - 3.5
        }
    }
    
    func changeSkinOfNode(node: SKSpriteNode, imageName: String) {
        let skin = SKTexture(imageNamed: imageName)
        let pause = SKAction.waitForDuration(0.3)
        let changeSkin = SKAction.runBlock {
            self.granny.texture = skin
        }
        node.runAction(SKAction.sequence([pause, changeSkin]))
    }
    
    func backfireOrMuzzle(imageNameShoot: String, imageNameAfterShoot: String) {
        granny.texture = SKTexture(imageNamed: imageNameShoot)
        
        let wait = SKAction.waitForDuration(0.3)
        let run = SKAction.runBlock {
            self.granny.texture = SKTexture(imageNamed: imageNameAfterShoot)
        }
        granny.runAction(SKAction.sequence([wait, run]))
    }
    
    func shootProjectile(projectile: SKSpriteNode, touchLocation: CGPoint) {
        backfireOrMuzzle("granny-ak47-muzzle", imageNameAfterShoot: "granny-ak47-no-muzzle")
        
        let y = touchLocation.y - projectile.position.y
        let x = touchLocation.x - projectile.position.x
        let angle = atan2(y, x)
        let offset = touchLocation - projectile.position
        
        if (offset.x < 0) { return }
        
        let direction = offset.normalized()
        let shootAmount = direction * 800
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        let projectileTilt = SKAction.rotateToAngle(angle, duration: 0.0)
        let grannyMove = SKAction.rotateToAngle(angle, duration: 1.0)
        let grannyMoveBack = SKAction.rotateToAngle(0, duration: 1.0)
        
        self.addChild(projectile)
        projectile.runAction(SKAction.sequence([projectileTilt, actionMove, actionMoveDone]))
        granny.runAction(SKAction.sequence([grannyMove, grannyMoveBack]))
    }
    
    func shootRocket(projectile: SKSpriteNode, touchLocation: CGPoint) {
        backfireOrMuzzle("granny-rpg-with-fire", imageNameAfterShoot: "granny-rpg-no-fire")
        
        let y = touchLocation.y - projectile.position.y
        let x = touchLocation.x - projectile.position.x
        let angle = atan2(y, x)
        let offset = touchLocation - projectile.position
        
        if (offset.x < 0) { return }
        
        let direction = offset.normalized()
        let shootAmount = direction * 1000
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        let projectileTilt = SKAction.rotateToAngle(angle, duration: 0.0)
        let grannyMove = SKAction.rotateToAngle(angle, duration: 1.0)
        let grannyMoveBack = SKAction.rotateToAngle(0, duration: 1.0)
        
        self.addChild(projectile)
        projectile.runAction(SKAction.sequence([projectileTilt, actionMove, actionMoveDone]))
        granny.runAction(SKAction.sequence([grannyMove, grannyMoveBack]))
        changeSkinOfNode(granny, imageName: self.grannyImageNoMuzzle)
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
        } else if (firstBody.categoryBitMask == 0b1 && ((secondBody.categoryBitMask == 0b11) || (secondBody.categoryBitMask == 0b100))) {
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
        if (self.view?.paused == true) {
            self.view?.paused = false
        }
        
        if countDownDone {
            let bullet = RTAMBullet(size: CGSizeMake(13, 5), texture: SKTexture(imageNamed: "bullet"))
            let rocket = RTAMBullet(size: CGSizeMake(15, 5), texture: SKTexture(imageNamed: "rocket"))
            
            bullet.position = bulletPos.position
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
            bullet.physicsBody?.dynamic = true
            bullet.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
            bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            bullet.name = "bullet"
            
            rocket.position = bulletPos.position
            rocket.physicsBody = SKPhysicsBody(rectangleOfSize: rocket.size)
            rocket.physicsBody?.dynamic = true
            rocket.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            rocket.physicsBody?.contactTestBitMask = PhysicsCategory.Bird
            rocket.physicsBody?.collisionBitMask = PhysicsCategory.None
            rocket.physicsBody?.usesPreciseCollisionDetection = true
            rocket.name = "rocket"
            
            guard let touch = touches.first else {
                return
            }
            
            let touchLocation = touch.locationInNode(self)
            
            if (self.nodeAtPoint(touchLocation).name == "bg") {
                
                if (!isRpgSelected) {
                    shootProjectile(bullet, touchLocation: touchLocation)
                    shootingTimer = NSTimer.scheduledTimerWithTimeInterval(0.19, target: self, selector: Selector("playShootingSoundAK47"), userInfo: nil, repeats: false)
                } else {
                    isRpgSelected = false
                    shootRocket(rocket, touchLocation: touchLocation)
                    shootingTimer = NSTimer.scheduledTimerWithTimeInterval(0.19, target: self, selector: Selector("playShootingSoundRpg"), userInfo: nil, repeats: false)
                }
            }
            
            if ((self.nodeAtPoint(touchLocation).name == "bazooka") && (useRpg.alpha == 1)) {
                isRpgSelected = true
                useRpg.alpha = 0.5
                changeSkinOfNode(granny, imageName: self.grannyImageNoBackfire)
                let waitForAlpha = SKAction.waitForDuration(5)
                let changeAlphaBack = SKAction.runBlock{self.useRpg.alpha = 1}
                useRpg.runAction(SKAction.sequence([waitForAlpha, changeAlphaBack]))
            }
        }
    }
    
    func projectileDidCollideWithMonster(bird: SKSpriteNode, bullet: SKSpriteNode) {
        if (bullet.name == "rocket") {
            for (var i = 0; i < birdManager.birds.count ; i++) {
                let birdInLoop = birdManager.birds[i]
                
                var explodeImage = ""
                
                if (birdInLoop?.name == "green-bird") {
                    explodeImage = "green-bird-explode-last"
                } else if (birdInLoop?.name == "yellow-bird") {
                    explodeImage = "yellow-bird-explode-last"
                }
                
                let birdExplode = SKTexture(imageNamed: explodeImage)
                birdExplode.filteringMode = SKTextureFilteringMode.Nearest
                
                let explode = SKAction.animateWithTextures([birdExplode], timePerFrame:0.1);
                let removeBird = SKAction.removeFromParent()
                birdInLoop?.runAction(SKAction.sequence([explode, removeBird]))
            }
        } else {
            var explodeImage = ""
            
            if (bird.name == "green-bird") {
                explodeImage = "green-bird-explode-last"
            } else if (bird.name == "yellow-bird") {
                explodeImage = "yellow-bird-explode-last"
            }
            
            let birdExplode = SKTexture(imageNamed: explodeImage)
            birdExplode.filteringMode = SKTextureFilteringMode.Nearest
            
            let explode = SKAction.animateWithTextures([birdExplode], timePerFrame:0.1);
            let removeBird = SKAction.removeFromParent()
            
            bird.runAction(SKAction.sequence([explode, removeBird]))
        }
        
        bullet.removeFromParent()
        updateScore()
    }
    
    func birdDidCollideWithGranny(bird: SKSpriteNode, granny: SKSpriteNode) {
        if (numberOfGrannyHitsLeft > 0) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            var explodeImage = ""
            
            if (bird.name == "green-bird") {
                explodeImage = "green-bird-explode-last"
            } else if (bird.name == "yellow-bird") {
                explodeImage = "yellow-bird-explode-last"
            }
            
            let birdExplode = SKTexture(imageNamed: explodeImage)
            birdExplode.filteringMode = SKTextureFilteringMode.Nearest
            
            let explode = SKAction.animateWithTextures([birdExplode], timePerFrame:0.1);
            let removeBird = SKAction.removeFromParent()
            
            bird.runAction(SKAction.sequence([explode, removeBird]))
            
            numberOfGrannyHitsLeft = numberOfGrannyHitsLeft - 1
            numberOfBalloonsLeft  = numberOfBalloonsLeft - 1
            balloonImage = balloonImages[numberOfBalloonsLeft]
            
            self.balloons.texture = SKTexture(imageNamed: balloonImage)
            
            if (self.numberOfGrannyHitsLeft) == 0 {
                mainInstance.score = self.score
                gamescene_delegate?.gameOverDelegateFunc()
                self.gameOver = true
                self.view?.paused = true
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if (!gameOver) {
            if self.countDownDone {
                if currentTime - self.lastBirdAdded > 0.6 {
                    self.lastBirdAdded = currentTime + 0.6
                    
                    let bird = self.birdManager.addBird(self, birdName: "yellow-bird")!
                    self.addChild(bird)
                    
                    let topBird = self.birdManager.addBirdFromTop(self, birdName: "yellow-bird")!
                    self.addChild(topBird)
                    
                    let bottomBird = self.birdManager.addBirdFromBottom(self, birdName: "green-bird")!
                    self.addChild(bottomBird)
                }
            }
        }
    }
}