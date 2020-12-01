// TerrainPresetLoader.swift
// Copyright (c) 2020 Dylan Gattey

import Combine
import Debug
import Foundation

/// Loads and saves terrain presets to disk
enum TerrainPresetLoader {
    /// An error we might run into in loading/saving presets
    enum PresetError: Error {
        case encodingError(EncodingError)
        case decodingError(DecodingError)
        case message(String)

        fileprivate init(_ error: Error) {
            switch error {
            case let error as EncodingError:
                self = .encodingError(error)
            case let error as DecodingError:
                self = .decodingError(error)
            default:
                self = .message(error.localizedDescription)
            }
        }
    }

    /// The type of file we save
    private static let fileExtension = "json"

    /// Name of the folder where presets are stored
    private static let presetsFolderName = "Terrain Presets"

    /// The URL for the presets folder (in containers)
    static var presetsFolderURL: URL {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsFolder.appendingPathComponent(presetsFolderName)
    }

    /// Easier way to grab the path itself for the presets folder
    static var presetsFolderPath: String {
        presetsFolderURL.path
    }

    /// Location of default presets - will get created if they don't exist
    private static var defaultPresetsPath: String {
        return presetsFolderURL
            .appendingPathComponent(filename(TerrainPresetData.default))
            .appendingPathExtension(fileExtension)
            .path
    }

    /// Creates a preset filename from a preset name
    private static func filename(_ preset: TerrainPresetData) -> String {
        return preset.presetName.decomposedStringWithCanonicalMapping
    }

    /// Creates the presets folder itself if it's missing (on a background thread).
    private static func ensureDefaultDataCreated() -> AnyPublisher<Void, PresetError> {
        return Future { promise in
            DispatchQueue.global(qos: .utility).async {
                guard !FileManager.default.fileExists(atPath: presetsFolderPath) else {
                    promise(.success(()))
                    return
                }
                do {
                    try FileManager.default.createDirectory(
                        atPath: presetsFolderPath,
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                } catch {
                    promise(.failure(.message("Couldn't create presets folder")))
                }
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    /// Saves the given preset to disk in the presets folder - returns a promise
    /// with the preset name. Does all work on a background thread.
    static func savePreset(_ preset: TerrainPresetData) -> AnyPublisher<String, PresetError> {
        let presetPath = presetsFolderURL
            .appendingPathComponent(filename(preset))
            .appendingPathExtension(fileExtension)
            .path

        // Encodes and saves the file
        let saveFiles = { () -> AnyPublisher<String, PresetError> in
            let encoder = JSONEncoder()
            encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "∞", negativeInfinity: "-∞", nan: "NAN")
            return Just(preset)
                .encode(encoder: encoder)
                .mapError { PresetError($0) }
                .map { data in
                    FileManager.default.createFile(atPath: presetPath, contents: data, attributes: nil)
                    return preset.presetName
                }
                .eraseToAnyPublisher()
        }
        return ensureDefaultDataCreated()
            .receive(on: DispatchQueue.global(qos: .utility))
            .flatMap(saveFiles)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Loads all files in the presets folder to try converting them to presets. Will
    /// run on a background thread and return a mapping of name -> preset as a Future.
    /// Also saves the default preset!!
    static func loadPresets() -> AnyPublisher<[String: TerrainPresetData], PresetError> {
        /// Actually loads files using the enumerator into presets
        let loadPresets: (NSEnumerator) -> AnyPublisher<[TerrainPresetData], PresetError> = { enumerator in
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "∞", negativeInfinity: "-∞", nan: "NAN")

            // Try decoding each file recursively in the subdirectory
            let presetPublishers = enumerator
                .compactMap { $0 as? URL }
                .map(checkFileType)
                .map { fileURLPublisher in
                    // Each file URL should be decoded to terrain preset data
                    fileURLPublisher
                        .tryMap { try Data(contentsOf: $0) }
                        .decode(type: TerrainPresetData.self, decoder: decoder)
                        .mapError { PresetError($0) }
                        .eraseToAnyPublisher()
                }

            // Combines all presets into one array
            return Publishers.MergeMany(presetPublishers)
                .collect()
                .eraseToAnyPublisher()
        }
        // Save the default preset, then load presets on a background thread
        return savePreset(TerrainPresetData.default)
            .receive(on: DispatchQueue.global(qos: .utility))
            .flatMap(createPresetsEnumerator)
            .flatMap(loadPresets)
            .map { presets -> [String: TerrainPresetData] in
                // Map the array to a dict with keys being the preset names
                let keys = presets.map { $0.presetName }
                return Dictionary(uniqueKeysWithValues: zip(keys, presets))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Checks a url's file type to make sure it's a real file
    private static func checkFileType(of fileURL: URL) -> AnyPublisher<URL, PresetError> {
        // Each file has to be a regular file otherwise it can't be converted
        if let fileAttributes = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
           fileAttributes.isRegularFile ?? false
        {
            return Just(fileURL)
                .setFailureType(to: PresetError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: PresetError.message("Irregular file: \(fileURL)"))
            .eraseToAnyPublisher()
    }

    /// Creates a file enumerator for the presets folder if possible
    private static func createPresetsEnumerator(_: String) -> AnyPublisher<NSEnumerator, PresetError> {
        guard let enumerator = FileManager.default.enumerator(
            at: presetsFolderURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsPackageDescendants, .skipsHiddenFiles],
            errorHandler: nil
        )
        else {
            return Fail(error: PresetError.message("Couldn't create a file enumerator for \(presetsFolderURL)"))
                .eraseToAnyPublisher()
        }
        return Just(enumerator)
            .setFailureType(to: PresetError.self)
            .eraseToAnyPublisher()
    }
}
