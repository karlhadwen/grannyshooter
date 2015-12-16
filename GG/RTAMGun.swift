import Foundation
import SpriteKit

//TODO: This RTAMGun is representing the granny...
class RTAMGun: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "granny"), color: UIColor.blackColor(), size: CGSizeMake(size.width,  size.height))
        anchorPoint = CGPointMake(0, 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}