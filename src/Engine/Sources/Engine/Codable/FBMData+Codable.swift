// FBMData+Codable.swift
// Copyright (c) 2020 Dylan Gattey

import Foundation

/// This is defined in .h file so putting it here for conformance
extension FBMData: Codable {
    enum CodingKeys: String, CodingKey {
        case octaves
        case persistence
        case scale
        case compression
        case seed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(octaves, forKey: .octaves)
        try container.encode(persistence, forKey: .persistence)
        try container.encode(scale, forKey: .scale)
        try container.encode(compression, forKey: .compression)
        try container.encode(seed, forKey: .seed)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let octaves = try values.decode(Int32.self, forKey: .octaves)
        let persistence = try values.decode(Float.self, forKey: .persistence)
        let scale = try values.decode(Float.self, forKey: .scale)
        let compression = try values.decode(Float.self, forKey: .compression)
        let seed = try values.decode(UInt32.self, forKey: .seed)
        self.init(octaves: octaves, persistence: persistence, scale: scale, compression: compression, seed: seed)
    }
}
