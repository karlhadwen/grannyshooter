import Foundation
import SpriteKit

class RTAMBullet: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "bullet"), color: UIColor.blackColor(), size: CGSizeMake(size.width,  size.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}