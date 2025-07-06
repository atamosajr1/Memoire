//
//  AppConfig.swift
//  EventVideo
//
//  Created by JayR Atamosa on 1/15/25.
//

import Foundation

final class AppConfig {
    // MARK: - Properties
    var settings: Settings?
    
    // MARK: - Singleton Instance
    static let shared = AppConfig()
    
    // MARK: - Initializer
    private init() {
        // Private to prevent direct instantiation
        readSettingsFromAdminFolder()
    }
    
    func readSettingsFromAdminFolder() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to find document directory")
            return
        }

        let adminFolderURL = documentDirectory.appendingPathComponent("admin")
        let settingsFileURL = adminFolderURL.appendingPathComponent("settings.json")

        if fileManager.fileExists(atPath: settingsFileURL.path) {
            do {
                let data = try Data(contentsOf: settingsFileURL)
                let decoder = JSONDecoder()
                settings = try decoder.decode(Settings.self, from: data)
                print("Settings loaded successfully")
            } catch {
                print("Failed to decode settings: \(error)")
            }
        } else {
            print("Settings file does not exist.")
        }
    }

}
