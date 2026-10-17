//
//  ModelStore.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import Foundation
///
/// Model Store - Use for store model into local directory for development
/// The model file can be several gigabytes, so importing it requires adequate free storage. For a production release, add a storage check, duplicate-file handling, download progress if you offer downloads, and a delete-model option.
///
enum ModelStore {
    static let preferenceKey = "aigoal.modelFilename"

    static var documentsDirectory: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
    }

    static var currentModelURL: URL? {
        let filename = UserDefaults.standard.string(
            forKey: preferenceKey
        ) ?? ""

        guard !filename.isEmpty else { return nil }

        let url = documentsDirectory.appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        return url
    }

    static func importModel(from sourceURL: URL) throws -> URL {
        let didAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        guard sourceURL.pathExtension.lowercased() == "gguf" else {
            throw ModelStoreError.invalidFile
        }

        let filename = sourceURL.lastPathComponent
        let destination = documentsDirectory
            .appendingPathComponent(filename)

        if sourceURL.standardizedFileURL != destination.standardizedFileURL {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }

            try FileManager.default.copyItem(
                at: sourceURL,
                to: destination
            )
        }

        UserDefaults.standard.set(
            filename,
            forKey: preferenceKey
        )

        return destination
    }
}

enum ModelStoreError: LocalizedError {
    case invalidFile

    var errorDescription: String? {
        switch self {
        case .invalidFile:
            return "Please choose a valid .gguf model file."
        }
    }
}
