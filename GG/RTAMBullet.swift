//
//  RTAMBullet.swift
//  GG
//
//  Created by Karl Hadwen on 22/11/2015.
//  Copyright (c) 2015 Karl Hadwen. All rights reserved.
//

import Foundation
import SpriteKit

class RTAMBullet: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.blackColor() , size: CGSizeMake( size.width,  size.height))
        anchorPoint = CGPointMake(0, 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}