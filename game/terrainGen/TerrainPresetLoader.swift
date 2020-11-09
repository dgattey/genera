//
//  TerrainPresetLoader.swift
//  Genera
//
//  Created by Dylan Gattey on 11/8/20.
//

import Foundation

/// Loads and saves terrain presets to disk
enum TerrainPresetLoader {
    
    /// The type of file we save
    private static let fileExtension = "json"
    
    /// Name of the folder where presets are stored
    private static var presetsFolderName = "generaPresets"
    
    /// The URL for the presets folder (in containers)
    static var presetsFolderURL: URL {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsFolder.appendingPathComponent(presetsFolderName)
    }
    
    /// Easier way to grab the path itself for the presets folder
    static var presetsFolderPath: String {
        return presetsFolderURL.path
    }
    
    /// Location of default presets - will get created if they don't exist
    private static var defaultPresetsPath: String {
        return presetsFolderURL.appendingPathComponent(DefaultTerrainData.presetID).appendingPathExtension(fileExtension).path
    }
    
    /// Creates the presets folder itself if it's missing
    private static func createPresetsFolderIfNonexistent() {
        if !FileManager.default.fileExists(atPath: presetsFolderPath) {
            do {
                try FileManager.default.createDirectory(atPath: presetsFolderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.log("Problem creating presets folder: \(error.localizedDescription)")
            }
        }
        // Save default preset too if missing
        if !FileManager.default.fileExists(atPath: defaultPresetsPath) {
            savePreset(DefaultTerrainData.terrainData)
        }
    }
    
    /// Saves the given preset to disk in the presets folder
    static func savePreset(_ preset: TerrainData, onCompletion: ((_ presetName: String) -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            createPresetsFolderIfNonexistent()
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(preset) else {
                Logger.log("Couldn't create data")
                return
            }
            let path = presetsFolderURL.appendingPathComponent(preset.presetID).appendingPathExtension(fileExtension).path
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
            onCompletion?(preset.presetName)
        }
    }
    
    /// Loads all plists in the presets folder to try converting them - doesn't run from a background queue
    static func loadPresets() -> [TerrainData] {
        createPresetsFolderIfNonexistent()
        let decoder = JSONDecoder()

        var terrainDataArray: [TerrainData] = []
        guard let enumerator = FileManager.default.enumerator(at: presetsFolderURL,
                                                              includingPropertiesForKeys: [.isRegularFileKey],
                                                              options: [.skipsPackageDescendants, .skipsHiddenFiles],
                                                              errorHandler: nil) else {
            return terrainDataArray
        }
        
        // Try decoding each file recursively in the subdirectory
        for case let fileURL as URL in enumerator {
            guard let fileAttributes = try? fileURL.resourceValues(forKeys:[.isRegularFileKey]),
               fileAttributes.isRegularFile ?? false else {
                // Not a real file
                continue
            }
            if let fileData = try? Data.init(contentsOf: fileURL),
               let terrainData = try? decoder.decode(TerrainData.self, from: fileData) {
                terrainDataArray.append(terrainData)
            } else {
                Logger.log("Didn't convert \(fileURL) to a valid preset")
            }
        }
        return terrainDataArray
    }

}