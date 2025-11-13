//
//  AppDataManager.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 13/11/25.
//

import Foundation

/// Manages the application's data directory structure in Library/Application Support
class AppDataManager {
    
    // MARK: - Singleton
    static let shared = AppDataManager()
    
    // MARK: - Directory Structure
    enum AppDirectory: String, CaseIterable {
        case docs = "Docs"
        case firmwareImages = "Firmware_Images"
        case graphingProfiles = "Graphing_Profiles"
        case profiles = "Profiles"
        case roastGraphsNotes = "Roast_Graphs+Notes"
        case roastLog = "Roast_Log"
        case bleDevices = "BLE_Devices"
        case hardware = "Hardware"
        case rorLogs = "RoR_Logs"
        
        var description: String {
            switch self {
            case .docs:
                return "Documentation and user guides"
            case .firmwareImages:
                return "Firmware update images"
            case .graphingProfiles:
                return "Graphing configuration profiles"
            case .profiles:
                return "Roast profiles"
            case .roastGraphsNotes:
                return "Roast graphs and notes"
            case .roastLog:
                return "Roast session logs"
            case .bleDevices:
                return "Bluetooth device configurations"
            case .hardware:
                return "Hardware configurations"
            case .rorLogs:
                return "Rate of Rise logs"
            }
        }
    }
    
    // MARK: - Properties
    private let fileManager = FileManager.default
    private let appName = "Roast-Tech"
    
    /// The root application support directory for Roast-Tech
    private(set) var applicationSupportURL: URL?
    
    /// Dictionary of all subdirectory URLs
    private(set) var directoryURLs: [AppDirectory: URL] = [:]
    
    // MARK: - Initialization
    private init() {
        setupDirectoryStructure()
    }
    
    // MARK: - Directory Setup
    
    /// Sets up the complete directory structure for the application
    private func setupDirectoryStructure() {
        do {
            // Get the Application Support directory
            guard let appSupportURL = try? fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ) else {
                print("❌ Failed to locate Application Support directory")
                return
            }
            
            // Create Roast-Tech root directory
            let roastTechURL = appSupportURL.appendingPathComponent(appName)
            try createDirectoryIfNeeded(at: roastTechURL)
            applicationSupportURL = roastTechURL
            
            // Create all subdirectories
            for directory in AppDirectory.allCases {
                let directoryURL = roastTechURL.appendingPathComponent(directory.rawValue)
                try createDirectoryIfNeeded(at: directoryURL)
                directoryURLs[directory] = directoryURL
                print("✅ Created directory: \(directory.rawValue)")
            }
            
            print("✅ Successfully initialized Roast-Tech directory structure at: \(roastTechURL.path)")
            
        } catch {
            print("❌ Error setting up directory structure: \(error.localizedDescription)")
        }
    }
    
    /// Creates a directory if it doesn't already exist
    /// - Parameter url: The URL where the directory should be created
    private func createDirectoryIfNeeded(at url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    // MARK: - Public API
    
    /// Returns the URL for a specific application directory
    /// - Parameter directory: The directory to retrieve
    /// - Returns: URL of the requested directory, or nil if not available
    func url(for directory: AppDirectory) -> URL? {
        return directoryURLs[directory]
    }
    
    /// Returns the path string for a specific application directory
    /// - Parameter directory: The directory to retrieve
    /// - Returns: Path string of the requested directory, or nil if not available
    func path(for directory: AppDirectory) -> String? {
        return directoryURLs[directory]?.path
    }
    
    /// Creates a file URL within a specific directory
    /// - Parameters:
    ///   - filename: The name of the file
    ///   - directory: The directory where the file should be located
    /// - Returns: Complete URL for the file
    func fileURL(filename: String, in directory: AppDirectory) -> URL? {
        return directoryURLs[directory]?.appendingPathComponent(filename)
    }
    
    /// Lists all files in a specific directory
    /// - Parameter directory: The directory to list
    /// - Returns: Array of file URLs, or empty array if directory doesn't exist or is empty
    func listFiles(in directory: AppDirectory) -> [URL] {
        guard let directoryURL = directoryURLs[directory] else {
            return []
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            return files.filter { url in
                (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
            }
        } catch {
            print("❌ Error listing files in \(directory.rawValue): \(error.localizedDescription)")
            return []
        }
    }
    
    /// Checks if a file exists at the specified location
    /// - Parameters:
    ///   - filename: The name of the file
    ///   - directory: The directory to check
    /// - Returns: True if the file exists, false otherwise
    func fileExists(filename: String, in directory: AppDirectory) -> Bool {
        guard let fileURL = fileURL(filename: filename, in: directory) else {
            return false
        }
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    /// Deletes a file from a specific directory
    /// - Parameters:
    ///   - filename: The name of the file to delete
    ///   - directory: The directory containing the file
    /// - Returns: True if deletion was successful, false otherwise
    @discardableResult
    func deleteFile(filename: String, in directory: AppDirectory) -> Bool {
        guard let fileURL = fileURL(filename: filename, in: directory) else {
            return false
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("✅ Deleted file: \(filename) from \(directory.rawValue)")
            return true
        } catch {
            print("❌ Error deleting file \(filename): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Saves data to a file in a specific directory
    /// - Parameters:
    ///   - data: The data to save
    ///   - filename: The name of the file
    ///   - directory: The directory where the file should be saved
    /// - Returns: True if save was successful, false otherwise
    @discardableResult
    func saveData(_ data: Data, filename: String, in directory: AppDirectory) -> Bool {
        guard let fileURL = fileURL(filename: filename, in: directory) else {
            return false
        }
        
        do {
            try data.write(to: fileURL)
            print("✅ Saved file: \(filename) to \(directory.rawValue)")
            return true
        } catch {
            print("❌ Error saving file \(filename): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Loads data from a file in a specific directory
    /// - Parameters:
    ///   - filename: The name of the file to load
    ///   - directory: The directory containing the file
    /// - Returns: The file's data, or nil if the file doesn't exist or can't be read
    func loadData(filename: String, from directory: AppDirectory) -> Data? {
        guard let fileURL = fileURL(filename: filename, in: directory) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("✅ Loaded file: \(filename) from \(directory.rawValue)")
            return data
        } catch {
            print("❌ Error loading file \(filename): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Copies a file from one directory to another
    /// - Parameters:
    ///   - filename: The name of the file to copy
    ///   - sourceDirectory: The source directory
    ///   - destinationDirectory: The destination directory
    ///   - newFilename: Optional new filename (uses original if nil)
    /// - Returns: True if copy was successful, false otherwise
    @discardableResult
    func copyFile(
        filename: String,
        from sourceDirectory: AppDirectory,
        to destinationDirectory: AppDirectory,
        newFilename: String? = nil
    ) -> Bool {
        guard let sourceURL = fileURL(filename: filename, in: sourceDirectory),
              let destinationURL = fileURL(filename: newFilename ?? filename, in: destinationDirectory) else {
            return false
        }
        
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("✅ Copied file: \(filename) from \(sourceDirectory.rawValue) to \(destinationDirectory.rawValue)")
            return true
        } catch {
            print("❌ Error copying file \(filename): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Moves a file from one directory to another
    /// - Parameters:
    ///   - filename: The name of the file to move
    ///   - sourceDirectory: The source directory
    ///   - destinationDirectory: The destination directory
    ///   - newFilename: Optional new filename (uses original if nil)
    /// - Returns: True if move was successful, false otherwise
    @discardableResult
    func moveFile(
        filename: String,
        from sourceDirectory: AppDirectory,
        to destinationDirectory: AppDirectory,
        newFilename: String? = nil
    ) -> Bool {
        guard let sourceURL = fileURL(filename: filename, in: sourceDirectory),
              let destinationURL = fileURL(filename: newFilename ?? filename, in: destinationDirectory) else {
            return false
        }
        
        do {
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
            print("✅ Moved file: \(filename) from \(sourceDirectory.rawValue) to \(destinationDirectory.rawValue)")
            return true
        } catch {
            print("❌ Error moving file \(filename): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Returns the size of a file in bytes
    /// - Parameters:
    ///   - filename: The name of the file
    ///   - directory: The directory containing the file
    /// - Returns: Size in bytes, or nil if file doesn't exist
    func fileSize(filename: String, in directory: AppDirectory) -> Int64? {
        guard let fileURL = fileURL(filename: filename, in: directory) else {
            return nil
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            return attributes[.size] as? Int64
        } catch {
            print("❌ Error getting file size for \(filename): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns the modification date of a file
    /// - Parameters:
    ///   - filename: The name of the file
    ///   - directory: The directory containing the file
    /// - Returns: Modification date, or nil if file doesn't exist
    func modificationDate(filename: String, in directory: AppDirectory) -> Date? {
        guard let fileURL = fileURL(filename: filename, in: directory) else {
            return nil
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            return attributes[.modificationDate] as? Date
        } catch {
            print("❌ Error getting modification date for \(filename): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Prints a summary of the directory structure
    func printDirectoryStructure() {
        guard let rootURL = applicationSupportURL else {
            print("❌ Application support directory not initialized")
            return
        }
        
        print("\n📁 Roast-Tech Directory Structure")
        print("Root: \(rootURL.path)")
        print("─────────────────────────────────")
        
        for directory in AppDirectory.allCases {
            if let url = directoryURLs[directory] {
                let fileCount = listFiles(in: directory).count
                print("📂 \(directory.rawValue) (\(fileCount) files)")
                print("   \(directory.description)")
            }
        }
        print("─────────────────────────────────\n")
    }
}

// MARK: - Convenience Extensions

extension AppDataManager {
    
    /// Quick access to common directories
    var profilesURL: URL? { url(for: .profiles) }
    var roastLogURL: URL? { url(for: .roastLog) }
    var firmwareURL: URL? { url(for: .firmwareImages) }
    var bleDevicesURL: URL? { url(for: .bleDevices) }
}
