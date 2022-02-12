//
//  Wave.swift
//  Zaptastic
//
//  Created by Deirdre Saoirse Moen on 4/16/19.
//  Copyright © 2019 Deirdre Saoirse Moen. All rights reserved.
//

import SpriteKit

struct Wave: Codable {
    struct WaveEnemy: Codable {
        var position: Int
        var xOffset: CGFloat
        var moveStraight: Bool
        var enemyImage: Int
    }
    
    var name: String
    var enemies: [WaveEnemy]
}

