//
//  EnemyNode.swift
//  Zaptastic My Attempt
//
//  Created by Ben  Thoburn on 02/02/2022.
//


import SpriteKit

class EnemyNode: SKSpriteNode {
//    var type: EnemyType
    var type: Wave.WaveEnemy
    var lastFiredTime: Double = 0
    var shields: Int
    var enemyType: EnemyType
    
//    init(type: EnemyType, startPosition: CGPoint, xOffset: CGFloat, moveStraight: Bool) {
//        self.type = type
//        shields = type.shields
    init(type: Wave.WaveEnemy, enemyType:EnemyType, names: String, position: CGPoint, xOffset: CGFloat, moveStraight: Bool) {
        self.type = type
        self.enemyType = enemyType
        shields = enemyType.shields
        
//        self.shields = shields
//        self.shields = enemyType.shields; Int()
//        self.shields = shields
        

        let texture = SKTexture(imageNamed: type.names)
//        let sheelds = enemyType.shields
        super.init(texture: texture, color: .white, size: texture.size())
//        super.init(shields: shields)
        self.setScale(4)
//        self.zRotation =  .pi / 2 // 90 degrees

        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        name = "enemy"
//        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        self.position = CGPoint(x: position.x + xOffset, y: position.y)
        
        configureMovement(moveStraight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("LOL NO")
    }
    
    func configureMovement(_ moveStraight: Bool){
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if moveStraight {
            path.addLine(to: CGPoint(x: -10000, y: 0))
        } else {
            path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y * 3.7), controlPoint2: CGPoint(x: -1100, y: -position.y))
        }
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true , speed: enemyType.speed)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
    }
    
    func fire() {
        let weaponType = "enemy1Weapon"
        
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
        
        weapon.physicsBody?.applyImpulse(CGVector(dx: dx , dy: dy))
        
    }
}
//dedicated initialiser of a sprite node is with texture
//offset is the current location of the sprite
//true means turn around so that it is always facing forwards on the path
//The self.type = is some form of enemy type as type is defined as an enemy type in the top of the class. It shares the qualities of the Enemy type swift struct.
//You have to create a variable at the top which does this so that it coforms to coding standards probably. Maybe it doesn't work if you don't.
//maybe you have to define it as self because you know that each type has an individual quality and you have to call to self to recognise that you want to take each specific
//if the SKPhysics body and  texture is equal to the name maybe you could create multiple ones with different names referencing different images in the assets and then create a different scale to program in for what type of hardness it is. 
//changing the type name weapon here's the original code.
//let weaponType = "\(type.name)Weapon". It's placed under func fire()
//the enemytype 3 is overlapping perhaps try to fix this issue with your code. Also change the name of the enemy 1 and 2 nodes as they seem to take up a lot of screen on the app.
//research how to rotate the image in the app.Also research how to change the size of the image within the app
//
//{
//    "position": 0,
//    "xOffset": 4,
//    "moveStraight": false
//},
//{
//    "position": 6,
//    "xOffset": 1,
//    "moveStraight": false
//},
//{
//    "position": 7,
//    "xOffset": 3,
//    "moveStraight": false
//},
//{
//    "position": 8,
//    "xOffset": 5,
//    "moveStraight": false
//},
