//
//  Waves.swift
//  Zaptastic My Attempt
//
//  Created by Ben  Thoburn on 02/02/2022.
//

import SpriteKit

struct Wave: Codable {
    struct WaveEnemy: Codable {
        let names: String
        let position: Int
        let xOffset: CGFloat
        let moveStraight: Bool
        let speed: CGFloat
    }
    let name: String
    var enemies: [WaveEnemy]
}
