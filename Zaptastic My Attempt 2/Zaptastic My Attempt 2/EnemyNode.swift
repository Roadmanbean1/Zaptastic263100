//hkjhkjhkhjkjh
import SpriteKit

class EnemyNode: SKSpriteNode {
    var type: EnemyType
    var lastFireTime: Double = 0
    var shields: Int
    var shieldAdder: Int
    var imagePicker: Int
    
    init(type: EnemyType, startPosition: CGPoint, xOffset: CGFloat, moveStraight: Bool, shieldAdder: Int, imagePicker: Int) {
        self.type = type
        self.shieldAdder = shieldAdder
        shields = type.shields + shieldAdder
        self.imagePicker = imagePicker
        
        let texture = SKTexture(imageNamed: type.name + "\(imagePicker)")
        super.init(texture: texture, color: .white, size: texture.size())
        
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        name = "enemy"
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        
        configureMovement(moveStraight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This method is not implemented.")
    }
    
    func configureMovement(_ moveStraight: Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if moveStraight {
            path.addLine(to: CGPoint(x: -10000, y: 0))
        } else {
            path.addCurve(to: CGPoint(x: 3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y * 3.7), controlPoint2:  CGPoint(x: -1000, y: -position.y))
        }
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: type.speed)
        
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
    
    func fire() {
        let weaponType = "\(type.name)Weapon"
        
        let weapon = SKSpriteNode(imageNamed: weaponType)
        weapon.name = "enemyWeapon"
        weapon.position = position
        weapon.zRotation = zRotation
        parent?.addChild(weapon)
        
        weapon.physicsBody = SKPhysicsBody(rectangleOf: weapon.size)
        weapon.physicsBody?.categoryBitMask = CollisionType.enemyWeapon.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.mass = 0.001
        
        let speed: CGFloat = 1
        let adjustedRotation = zRotation + (CGFloat.pi / 2)
        
        let dx = speed * cos(adjustedRotation)
        let dy = speed * sin(adjustedRotation)
        
        weapon.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
    }
}
// firstly finish this and save it in source controll so that you can access it later.

// maybe can change the shields by relating it to a new json file.  Which you could call shield type for simplicity.
