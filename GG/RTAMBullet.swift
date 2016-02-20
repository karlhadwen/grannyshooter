import Foundation
import SpriteKit

class RTAMBullet: SKSpriteNode {
    init(size: CGSize, texture: SKTexture) {
        super.init(texture: SKTexture(), color: UIColor.blackColor(), size: CGSizeMake(size.width,  size.height))
        self.texture = texture
        anchorPoint = CGPointMake(0, 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}