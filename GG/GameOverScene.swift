//
//  GameOverScene.swift
//  GG
//
//  Created by Karl Hadwen on 05/12/2015.
//  Copyright © 2015 Karl Hadwen. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        backgroundColor = SKColor.whiteColor()
        
        let message = won ? "You Won!" : "You Lose :["
        let label = SKLabelNode(fontNamed: "Chalkduster")
        
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(5.0),
            SKAction.runBlock() {
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
        ]))
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
