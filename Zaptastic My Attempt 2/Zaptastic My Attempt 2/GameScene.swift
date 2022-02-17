
//
//  GameScene.swift
//  Zaptastic
//
//  Created by Deirdre Saoirse Moen on 4/16/19.
//  Copyright © 2019 Deirdre Saoirse Moen. All rights reserved.
//

import CoreMotion
import SpriteKit
import Foundation
import FooFramework

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}
extension Bool {
    mutating func toggle() {
        self = !self
    }
}
public var cereal = 0
public func changeIt(){
    cereal = 1
}


//if car.integer == 1 {
//    DispatchQueue.main.async {
//        changeIt()
//
//
//    }
class GameScene: SKScene, SKPhysicsContactDelegate {
    open var car = Vehicle()
    
  
    
    let motionManager = CMMotionManager()
    let player = SKSpriteNode(imageNamed: "player")
    var playerShields = 10
    var isPlayerAlive = true
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    var levelNumber = 0
    var waveNumber = 0
    let positions = Array(stride(from: -160, through: 160, by: 40))

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: 1000, y: 0)
            particles.advanceSimulationTime(20)
            particles.zPosition = -1
            addChild(particles)
        }
        player.name = "player"
        player.position.x = frame.minX + 75
        player.zPosition = 1
        addChild(player)

        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())

        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.isDynamic = false
        
        motionManager.startAccelerometerUpdates()


    }

//    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToQuiz" {
//            let destinationVC = segue.destination as! Quiz
//            destinationVC.levelValue = levelNumber
//        }
//    }

    override func update(_ currentTime: TimeInterval) {
        if waveNumber == 1 {
            scene?.removeFromParent()
            
    //                    self.view = nil
           
        }
//        print(car.integer)
        

        if let accelerometerData = motionManager.accelerometerData {
            player.position.y += CGFloat(accelerometerData.acceleration.y * 50 )

            if player.position.y < frame.minY + 469 {
                player.position.y = frame.minY + 469
            } else if player.position.y > frame.maxY - 469 {
                player.position.y = frame.maxY - 469
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
//    func segue(){
//        self.view!.window!.rootViewController!.performSegue(withIdentifier: "Test", sender: self)
//    }
            
    
    func createWave() {
        guard isPlayerAlive else {return}
        
        

        if waveNumber == waves.count {
            DispatchQueue.main.async {
                changeIt()
                self.inputViewController?.performSegue(withIdentifier: "Play", sender: self)
            
            }
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
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true, shieldAdder: 0, imagePicker: 1)
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                //maybe create an integer variable inside this loop which gets increased every time a child is added. maybe that can be
                //create a shuffled array of stride which uses the maximum parameter of currentWave.enemies.count a uses a by of 1. create a previous wave count quality which becomes the lower bound of the stride.
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStraight: enemy.moveStraight, shieldAdder: 0, imagePicker: 1)
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
        addChild(shot)

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
            //When adding the explosion you can fastforward the animation a bit so that it looks more like the desired animation which you would like.
//
//            playerShields -= 1
//            print(playerShields)
//
//            if playerShields == 0 {
//                gameOver()
//                secondNode.removeFromParent()
//            }


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
//
