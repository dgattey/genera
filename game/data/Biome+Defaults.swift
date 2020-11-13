//
//  Biome+Defaults.swift
//  Genera
//
//  Created by Dylan Gattey on 11/5/20.
//

import AppKit

/// Extends the Obj-C defined Biome with some computed vars for use elsewhere
extension Biome {
    
    private static var ocean: Biome {
        return Biome(
            type: .ocean,
            color: vector_float3(0.2188037932, 0.210770309, 0.3924256861),
            minElevation: -Float.infinity,
            maxElevation: 0.05,
            maxMoisture: Float.infinity,
            blendRange: 0.02
        )
    }
    
    private static var shallowWater: Biome {
        return Biome(
            type: .shallowWater,
            color: vector_float3(0.3497013152, 0.329328239, 0.4814990759),
            minElevation: 0.05,
            maxElevation: 0.10,
            maxMoisture: Float.infinity,
            blendRange: 0.02
        )
    }
    
    private static var shore: Biome {
        return Biome(
            type: .shore,
            color: vector_float3(0.6381754875, 0.5679113269, 0.4531891346),
            minElevation: 0.1,
            maxElevation: 0.12,
            maxMoisture: 0.97,
            blendRange: 0.02
        )
    }
    
    private static var scorched: Biome {
        return Biome(
            type: .scorched,
            color: vector_float3(0.3333011568, 0.3333538771, 0.3332896829),
            minElevation: 0.8,
            maxElevation: Float.infinity,
            maxMoisture: 0.1,
            blendRange: 0.02
        )
    }
    
    private static var bare: Biome {
        return Biome(
            type: .bare,
            color: vector_float3(0.5332846642, 0.5333645344, 0.5332672),
            minElevation: 0.8,
            maxElevation: Float.infinity,
            maxMoisture: 0.2,
            blendRange: 0.02
        )
    }
    
    private static var tundra: Biome {
        return Biome(
            type: .tundra,
            color: vector_float3(0.7315357924, 0.7387986779, 0.6590853333),
            minElevation: 0.8,
            maxElevation: Float.infinity,
            maxMoisture: 0.5,
            blendRange: 0.02
        )
    }
    
    private static var snow: Biome {
        return Biome(
            type: .snow,
            color: vector_float3(0.8708811402, 0.8700690866, 0.9006112814),
            minElevation: 0.8,
            maxElevation: Float.infinity,
            maxMoisture: Float.infinity,
            blendRange: 0.02
        )
    }
    
    private static var temperateDesert1: Biome {
        return Biome(
            type: .temperateDesert,
            color: vector_float3(0.7777122855, 0.8286150098, 0.5814029574),
            minElevation: 0.6,
            maxElevation: 0.8,
            maxMoisture: 0.33,
            blendRange: 0.02
        )
    }
    
    private static var shrubland: Biome {
        return Biome(
            type: .shrubland,
            color: vector_float3(0.5155887008, 0.6048905253, 0.4522334337),
            minElevation: 0.6,
            maxElevation: 0.8,
            maxMoisture: 0.66,
            blendRange: 0.02
        )
    }
    
    private static var taiga: Biome {
        return Biome(
            type: .taiga,
            color: vector_float3(0.5767214894, 0.6726787686, 0.4422698319),
            minElevation: 0.6,
            maxElevation: 0.8,
            maxMoisture: Float.infinity,
            blendRange: 0.02
        )
    }
    
    private static var temperateDesert2: Biome {
        return Biome(
            type: .temperateDesert,
            color: vector_float3(0.7777122855, 0.8286150098, 0.5814029574),
            minElevation: 0.3,
            maxElevation: 0.6,
            maxMoisture: 0.16,
            blendRange: 0.02
        )
    }
    
    private static var grassland1: Biome {
        return Biome(
            type: .grassland,
            color: vector_float3(0.4925258756, 0.6802223325, 0.2770718932),
            minElevation: 0.3,
            maxElevation: 0.6,
            maxMoisture: 0.5,
            blendRange: 0.02
        )
    }
    
    private static var temperateDeciduousForest: Biome {
        return Biome(
            type: .temperateDeciduousForest,
            color: vector_float3(0.3480811715, 0.5857154727, 0.3204561472),
            minElevation: 0.3,
            maxElevation: 0.6,
            maxMoisture: 0.83,
            blendRange: 0.02
        )
    }
    
    private static var temperateRainforest: Biome {
        return Biome(
            type: .temperateRainforest,
            color: vector_float3(0.1177579537, 0.544154644, 0.3114391267),
            minElevation: 0.3,
            maxElevation: 0.6,
            maxMoisture: Float.infinity,
            blendRange: 0.02
        )
    }
    
    private static var subtropicalDesert: Biome {
        return Biome(
            type: .subtropicalDesert,
            color: vector_float3(0.8410642147, 0.7242162228, 0.5193104148),
            minElevation: 0,
            maxElevation: Float.infinity,
            maxMoisture: 0.16,
            blendRange: 0.02
        )
    }
    
    private static var grassland2: Biome {
        return Biome(
            type: .grassland,
            color: vector_float3(0.4925258756, 0.6802223325, 0.2770718932),
            minElevation: 0,
            maxElevation: Float.infinity,
            maxMoisture: 0.33,
            blendRange: 0.02
        )
    }
    
    private static var tropicalSeasonalForest: Biome {
        return Biome(
            type: .tropicalSeasonalForest,
            color: vector_float3(0.2234450281, 0.6123558879, 0.2096185088),
            minElevation: 0,
            maxElevation: Float.infinity,
            maxMoisture: 0.66,
            blendRange: 0.02
        )
    }
    
    private static var tropicalRainforest: Biome {
        return Biome(
            type: .tropicalRainforest,
            color: vector_float3(0, 0.476154685, 0.32167539),
            minElevation: 0,
            maxElevation: Float.infinity,
            maxMoisture: Float.infinity,
            blendRange: 0.02
        )
    }
    
    /// Array of biomes with different elevations and moistures
    static var defaultBiomes: [Biome] {
        return [
            ocean,
            shallowWater,
            shore,
            scorched,
            bare,
            tundra,
            snow,
            temperateDesert1,
            shrubland,
            taiga,
            temperateDesert2,
            grassland1,
            temperateDeciduousForest,
            temperateRainforest,
            subtropicalDesert,
            grassland2,
            tropicalSeasonalForest,
            tropicalRainforest,
        ]
    }
    
    /// Contains _a_ definition of biome type to biome color (assumes multiple biomes defined above have the same colors)
    static var defaultBiomeColors: Dictionary<BiomeType, vector_float4> {
        let rawColors: Dictionary<BiomeType, vector_float3> = [
            .ocean: ocean.color,
            .shallowWater: shallowWater.color,
            .shore: shore.color,
            .scorched: scorched.color,
            .bare: bare.color,
            .tundra: tundra.color,
            .snow: snow.color,
            .temperateDesert: temperateDesert1.color,
            .shrubland: shrubland.color,
            .taiga: taiga.color,
            .grassland: grassland1.color,
            .temperateDeciduousForest: temperateDeciduousForest.color,
            .temperateRainforest: temperateRainforest.color,
            .subtropicalDesert: subtropicalDesert.color,
            .tropicalSeasonalForest: tropicalSeasonalForest.color,
            .tropicalRainforest: tropicalRainforest.color,
        ]
        return rawColors.mapValues { vector_float4($0, 1.0) }
    }
    
    /// The NSColor representation of this biome's color
    var nsColor: NSColor {
        return NSColor(
            red: CGFloat(color.x),
            green: CGFloat(color.y),
            blue: CGFloat(color.z),
            alpha: 1.0
        )
    }
}
