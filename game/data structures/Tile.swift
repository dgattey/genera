//
//  Tile.swift
//  Genera
//
//  Created by Dylan Gattey on 10/29/20.
//

import Metal
import simd

/// A position + type of tile that appears on the map
class Tile {
    
    // MARK: - types
    
    // Dictates which kind of tile this is
    enum Kind: Int {
        
        /// Shallow coastal water
        case water = 0
        
        /// Deeper water, for use out to sea
        case deepWater
        
        /// Sand, for use next to water
        case sand
        
        /// Grass for the plains
        case grass
        
        /// Trees, appearing on plains
        case tree
        
        /// Snow for the high elevations
        case snow
        
        /// This should be kept up to date with the number of tile kinds!
        static let total = 6
        
        /// The corresponding tile color, expressed as a 4 item float array from 0...1
        var color: [Float] {
            switch self {
            case .water:
                return Color.components(from: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
            case .deepWater:
                return Color.components(from: #colorLiteral(red: 0.01003021654, green: 0.3346161246, blue: 0.715423286, alpha: 1))
            case .sand:
                return Color.components(from: #colorLiteral(red: 0.7593135834, green: 0.7986099124, blue: 0.6198268533, alpha: 1))
            case .grass:
                return Color.components(from: #colorLiteral(red: 0, green: 0.7016168237, blue: 0.1941453218, alpha: 1))
            case .tree:
                return Color.components(from: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1))
            case .snow:
                return Color.components(from: #colorLiteral(red: 0.9536334872, green: 0.957352221, blue: 1, alpha: 1))
            }
        }
    }
    
    // MARK: - variables
    
    let x: Float
    let y: Float
    let kind: Kind
    
    init(x: Int, y: Int, kind: Kind = .water) {
        self.x = Float(x)
        self.y = Float(y)
        self.kind = kind
        
    }
    
    /// An array of xy vertices, with which to draw multiple triangles
    lazy var vertices: [Float] = {
        return [
            x, y,
            x + 1, y + 1,
            x + 1, y,
            x, y + 1,
            x + 1, y + 1,
            x, y,
        ]
    }()
    
    /// Color array, one rgba color for each vertex
    lazy var colors: [Float] = {
        return (0..<Size.verticesPerTile).flatMap({ _ in
            return kind.color
        })
    }()
}
