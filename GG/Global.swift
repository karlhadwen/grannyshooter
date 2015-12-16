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