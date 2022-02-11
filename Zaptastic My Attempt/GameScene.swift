import CoreMotion
import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let motionManager = CMMotionManager()
    
    let player = SKSpriteNode(imageNamed: "player")
    var playerShields = 10

    var isPlayerAlive = true
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    var levelNumber = 0
    var waveNumber = 0
    let positions = Array(stride(from: -320, through: 320, by: 80))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: 1000, y: 0)
            particles.advanceSimulationTime(20)
            particles.zPosition = -1
            addChild(particles)
        }
        
        player.position.x = frame.minX + 75
        player.zPosition = 1
        
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.isDynamic = false
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if let accelerometerData = motionManager.accelerometerData {
            player.position.y += CGFloat(accelerometerData.acceleration.x * 50)
            
            if player.position.y < frame.minY {
                player.position.y = frame.minY
            } else if player.position.y > frame.maxY {
                player.position.y = frame.maxY
            }
        }
        
        for child in children {
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }
        
        let activeEnemies = children.compactMap({$0 as? EnemyNode})
        
        if activeEnemies.isEmpty {
            createWave()
        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else {continue}
            
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime
                
                if Int.random(in: 0...6) == 0 {
                    enemy.fire()
                }
            }
        }
    }
    
    func createWave() {
        guard isPlayerAlive else {return}
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber % waves.count]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 600
        
        if currentWave.enemies.isEmpty {
            for (index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true)
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStraight: enemy.moveStraight)
                addChild(node)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        
        let shot = SKSpriteNode(imageNamed: "playerWeapon")
        shot.name = "playerWeapon"
        shot.position = player.position
        
        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.mass = 0.001

        let movement = SKAction.move(to: CGPoint(x: 1900, y: shot.position.y), duration: 5)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]

        if secondNode.name == "player" {
            guard isPlayerAlive else { return }
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            
            playerShields -= 1
            print(playerShields)
            
            if playerShields == 0 {
                gameOver()
                secondNode.removeFromParent()
            }
            
            
        } else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                
                enemy.removeFromParent()
            }
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            
            secondNode.removeFromParent()
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    func gameOver() {
        isPlayerAlive = false
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }

        if let gameOver = SKEmitterNode(fileNamed: "gameOver") {
            addChild(gameOver)
        }
    }
}




























































































////
////  GameScene.swift
////  Zaptastic My Attempt
////
////  Created by Ben  Thoburn on 02/02/2022.
////
//
//
//import SpriteKit
//import CoreMotion
//
//enum CollisionType: UInt32 {
//    case player = 1
//    case playerWeapon = 2
//    case enemy = 4
//    case enemyWeapon = 8
//}
//
//class GameScene: SKScene, SKPhysicsContactDelegate {
//    let motionManager = CMMotionManager()
//    let player = SKSpriteNode(imageNamed: "player")
//
//    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
//    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
//
//    var currentWave = 0
//    var isPlayerAlive = true
//    var levelNumber = 0
//    var waveNumber = 0
//    var playerShields = 10
//    let experiment  = Array(stride(from: 0, to: 9, by: 1)).shuffled()
//    let positions = Array(stride(from: -160, through: 160, by: 40)).shuffled()
//    let positions2 = Array(stride(from: -160, through: 160, by: 40))
//
//    let Oponents = Array(stride(from: 0, through: 9, by: 1))
//
//    override func didMove(to view: SKView) {
//        physicsWorld.gravity = .zero
//        physicsWorld.contactDelegate = self
//
//        if let particles = SKEmitterNode(fileNamed: "Starfield") {
//            particles.position = CGPoint(x: 1080, y: 0)
//            particles.advanceSimulationTime(60)
//            particles.zPosition = -1
//            addChild(particles)
//        }
//
//        player.name = "player"
//        player.position.x = frame.minX + 75
//        player.zPosition = 1
//        addChild(player)
//
//        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
//        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
//        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
//        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
//        player.physicsBody?.isDynamic = false
//
//        motionManager.startAccelerometerUpdates()
//    }
//
//
//    override func update(_ currentTime: TimeInterval) {
//        if let accelerometerData = motionManager.accelerometerData {
//            player.position.y += CGFloat(accelerometerData.acceleration.y * 50)
//            if player.position.y < frame.minY {
//                player.position.y = frame.minY
//            } else if player.position.y > frame.maxY {
//                player.position.y = frame.maxY
//            }
//        }
//        for child in children {
//            if child.frame.maxX < 0 {
//                if !frame.intersects(child.frame) {
//                    child.removeFromParent()
//                }
//            }
//        }
//
//        let activeEnemies = children.compactMap { $0 as? EnemyNode}
//
//        if activeEnemies.isEmpty {
//            createWave()
//        }
//        for enemy in activeEnemies {
//            guard frame.intersects(enemy.frame) else { continue }
//
//            if enemy.lastFiredTime + 1 < currentTime {
//                enemy.lastFiredTime = currentTime
//
//                if Int.random(in: 0...6) == 0 {
//                    enemy.fire()
//                }
//            }
//        }
//    }
//
//
//
//    func createWave() {
//        guard isPlayerAlive else {return}
//
//        if waveNumber == waves?.count {
//            // Changed this code from == wave.count
//            levelNumber += 1
//            waveNumber = 1
//        }
//
//        let currentWave = waves[waveNumber]
//        waveNumber += 1
//
//        let maximumEnemyType = min(enemyTypes?.count ?? 0, levelNumber + 1)
//        let enemyType = Int.random(in: 0..<maximumEnemyType)
//
//        let enemyOffsetX: CGFloat = 100
//        let enemyStartX = 800
//
//        if currentWave.enemies.isEmpty {
//                for (index, oponent) in Oponents.shuffled().enumerated() {
//                    let enemy = EnemyNode(type: , enemyType: enemyTypes[enemyType], names: "", position: CGPoint(x: enemyStartX, y: positions[oponent]), xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true)
//                        addChild(enemy)
//                    }
//                }
//            }
//        } else {
//            for enemy in currentWave.enemies {
////                for node in enemyTypes! {
////                for (_, oponent) in Oponents.shuffled().enumerated() {
////                for (index, oponent) in Oponents.shuffled().enumerated() {
//
//                let node = EnemyNode(type: waves[oponent], enemyType: enemyTypes[enemyType], names: "", position: CGPoint(x: enemyStartX, y: positions[oponent]), xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true)
//
//                addChild(node)
//
//
//
//            }
//        }
//    }
//
////    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isPlayerAlive else { return }
//
//        let shot = SKSpriteNode(imageNamed: "playerWeapon")
//        shot.name = "playerW§eapon"
//        shot.position = player.position
//
//        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
//        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
//        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
//        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
//        addChild(shot)
//
//        let movement = SKAction.move(to: CGPoint(x: 1900, y: shot.position.y), duration: 3)
//        let sequence = SKAction.sequence([movement, .removeFromParent()])
//        shot.run(sequence)
//    }
//
//    func didBegin(_ contact: SKPhysicsContact) {
//        guard let nodeA = contact.bodyA.node else { return }
//        guard let nodeB = contact.bodyB.node else { return }
//
//
//        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
//        let firstNode = sortedNodes[0]
//        let secondNode = sortedNodes[1]
//
//        if secondNode.name == "Player" {
//            guard isPlayerAlive else { return }
//
//            if let explosion  = SKEmitterNode(fileNamed: "Explosion") {
//                explosion.position = firstNode.position
//                addChild(explosion)
//            }
//
////            playerShields -= 1
////
////            if playerShields == 0 {
////
////                secondNode.removeFromParent()
////
////            }
////
////            firstNode.removeFromParent()
//        } else if let enemy = firstNode as? EnemyNode {
//            enemy.shields -= 1
//
//            if enemy.shields == 0 {
//                if let explosion  = SKEmitterNode(fileNamed: "Explosion") {
//                    explosion.position = enemy.position
//                    addChild(explosion)
//                }
//
//                enemy.removeFromParent()
//            }
//            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
//                explosion.position = enemy.position
//                addChild(explosion)
//            }
//            secondNode.removeFromParent()
//
//        }
//    }
//}
//// perhaps change the enemy startX when changing how far you want each enemy to be shifted off the screen when performing the enemy formation waves
////skphysics delegate on the game scene because you are ready to be told when collisions happen.
////Under did move to view contact delegate is self, so tell me when something happpens.
////        if currentWave.enemies.isEmpty {
////for (index, position) in positions.shuffled().enumerated() {
////    let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: CGFloat(index * 3), moveStraight: true)
////    addChild(enemy)
////}
////^^^^^ For the line above perhaps try and randomise the enemy type which enters the screen and then work from there. See how the code diagnoses other parts about your app to make it more interesting.
////Look in the enemy node swift File and see if you can change something about what type it is and stuff
////potential solution is to multiply everything by 10 then create 10 sets of easy medium and hard potential enemy types then when its doing the random lists it will have a larger set of enemies to randomise the selection from
////How to deal with the maximum enemy type problem -
////maybe you can add another index into the current wave enemies code which is for index, name. maybe this would randomise the names of the enemies to be different images in the xcassets
////and for (index, randomisedEnemyType) in bensEnemyTypes.shuffled().enumerated()
//
//
////Okay so the bt you were focussing on mainly, encompasses the properties of wave through obviously being initialised and through the type: bit it also adopts properties in the enemy-types json as it uses the decoded value being enemyTypes (as stated at the top of the file, to form the different enemy types in the game. Therefore you need to add more enemy types to the json file in order for more enemies to appear on the screen.
////maybe add another type of thing in here called enemy appearance and make it a UIImage and work with that not sure how it would work though.
// //Experiment by adding string names for the xcassets files into this waves Json to decide what the enemy node appearances are like.
////0 - 2 becomes 0 - 29
////test whether the enemy appearing at the top is the same every time, if so then there's an issue with the randomisation, test also whether you might have to create a new shuffled thing maybe do something else as to how you get different enemies to appear in formations.
////delete the random movement wave as it might be too complicated to do for now. Change the formation for the original wave so that it allows more spaces for words that you don't know rather than just 3 enemies in a line.
////Examine the case where the nodes are coming at you with each having different names.
////It's likely that the shuffled parameter has managed to select each node to a given position however because theres only 3 positions in the current wave, one of the final positions has multiple nodes on top of each other potentially.
////I shall have to experiment with creating more positions to see whether this effect goes away.
//
//
//
//
//
////                    let node = EnemyNode(type: enemyTypes[oponent], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStraight: enemy.moveStraight)
////                    Changing the for enemy bit at the top of this block to a for node
////                    I've changed the top bit from enemy to node and also updated everything after the node = to say node instead of enemy to see if this changes anything
////                    let node = EnemyNode(type: enemyTypes[oponent], startPosition: CGPoint(x: enemyStartX, y: (-280 + oponent * 70)), xOffset: enemyOffsetX * node.xOffset, moveStraight: node.moveStraight)
////                    let node = EnemyNode(type: enemyTypes[oponent], startPosition: CGPoint(x: enemyStartX , y: positions[node.position]), xOffset: enemyOffsetX * node.xOffset, moveStraight: node.moveStraight)
//                        //changing the oponents at the top removing the shuffled() seeing if this changes anythign
////                         Changing enemy type to a fixed value of 1 from oponent and seeing what happens
////                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y:   positions[node.position]), xOffset: enemyOffsetX * node.xOffset, moveStraight: true)
////This has been changed from a stride value of 70. Testing other things to see if they are the culprit
////    let bensEnemyTypes = Array(stride(from: 0, through: 9, by: 1))
////        let randomisedEnemyType = enemyTypes[enemyType]
////            let positions = Array(stride(from: -320, through: 320, by: 80)).shuffled()
////                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: CGFloat(index * 3), moveStraight: true)
////                addChild(enemy)
////                let enemy = EnemyNode(type: enemyTypes[oponent], startPosition: CGPoint(x: enemyStartX, y: (-280 + oponent * 70)), xOffset: CGFloat(index * 3), moveStraight: true)
//                // create a shuffled version of the positions array and then use that in the code
//                //changing the shields to a capital s to see whether it changes it to only be defined as one single variable
////                    for (_, oponent) in Oponents.shuffled().enumerated() {
////                    let node = EnemyNode(type: enemyTypes[oponent], startPosition: CGPoint(x: enemyStartX, y: (-280 + oponent * 70)), xOffset: CGFloat(index * 3 * oponent), moveStraight: true)
////                    let node = EnemyNode(type: wavesStuff[oponent], enemyType: enemyTypes[enemyType], names: "string", position: CGPoint(x: enemyStartX, y: positions2[node.position]), xOffset: enemyOffsetX, moveStraight: true)
////make the type of the enemy appear in the wave file and plan accordingly so that you can add each individual enemy's name in the wave file accordingly. Surely that's gonna work.
//
