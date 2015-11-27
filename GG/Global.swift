//
//  Global.swift
//  GG
//
//  Created by Karl Hadwen on 22/11/2015.
//  Copyright (c) 2015 Karl Hadwen. All rights reserved.
//
import SpriteKit

class Main {
    var granny = SKSpriteNode()
    let grannyCategory = 0x1 << 1
    let obstacleCategory = 0x1 << 2
    var actionMoveUp = SKAction()
    var actionMoveDown = SKAction()
    var name:String
    
    init(name:String) {
        self.name = name
    }
}

var mainInstance = Main(name:"Global Class")