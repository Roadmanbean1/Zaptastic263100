//
//  EnemyType.swift
//  Zaptastic My Attempt
//
//  Created by Ben  Thoburn on 02/02/2022.
//


import SpriteKit

struct EnemyType: Codable {
    let name: String
    let shields: Int
    let speed: CGFloat
    let powerUpChance: Int
}
