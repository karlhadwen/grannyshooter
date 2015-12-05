//
//  RTAMBirdManager.swift
//  GG
//
//  Created by Karl Hadwen on 04/12/2015.
//  Copyright © 2015 Karl Hadwen. All rights reserved.
//

import Foundation
import SpriteKit

class RTAMBirdManager {
    var birds = [RTAMBird?]()
    let birdInputLocations: [CGPoint] = [CGPoint(x: 10, y: 20), CGPoint(x: 30, y: 40), CGPoint(x: 50, y: 60)]
    
    func addBird(bird: RTAMBird) -> Bool? {
        let birdTest: RTAMBird? = bird
        let sizeOfArrayBeforeAdding: Int = getSizeOfArray()
        
        if let bird = birdTest {
            // bird is of type RTAMBird)
            self.birds[self.birds.count+1] = bird
            if (getSizeOfArray() > sizeOfArrayBeforeAdding) {
                return true
            }
        }
        return nil
    }

    
    func getSizeOfArray() -> Int {
        return self.birds.count;
    }
    
    func getBirdAtIndex(index: Int) -> RTAMBird? {
        if (index < self.birds.count && index >= 0) {
            return self.birds[index]
        } else {
            return nil;
        }
    }
    
    func randomiseBirdInputLocation() {
        
    }
    
    func removeBird(index: Int) {
        self.birds.removeAtIndex(index)
    }
}
