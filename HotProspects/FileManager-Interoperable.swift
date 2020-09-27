//
//  FileManager-Interoperable.swift
//  BucketList
//
//  Created by Gavin Butler on 29-08-2020.
//  Copyright © 2020 Gavin Butler. All rights reserved.
//

import Foundation

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = self.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func fileAlreadyExists(_ fileName: String) -> Bool {
        let url = Self.getDocumentsDirectory()
                .appendingPathComponent(fileName)
        return self.default.fileExists(atPath: url.path)
    }
    
    static func writeTo<T: CustomStringConvertible>(content: T, fileName: String) {
        let url = self.getDocumentsDirectory()
        .appendingPathComponent(fileName)
        
        let contentToWrite = content.description
        
        do {
            try contentToWrite.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            fatalError("Failed to write to: \(fileName) \(error.localizedDescription)")
        }
    }
    
    static func writeDataTo(content: Data, fileName: String) {
        let url = self.getDocumentsDirectory()
                .appendingPathComponent(fileName)
        do {
            try content.write(to: url)
        } catch {
            fatalError("Failed to write to: \(fileName) \(error.localizedDescription)")
        }
    }
    
    static func contentsOf(fileName: String) -> String {
        let url = self.getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let contents = try String(contentsOf: url)
            return contents
        } catch {
            fatalError("Failed to read from: \(fileName) \(error.localizedDescription)")
        }
    }
    
    static func dataContentsOf(fileName: String) -> Data {
            let url = self.getDocumentsDirectory().appendingPathComponent(fileName)
            
            do {
                let contents = try Data(contentsOf: url)
                return contents
            } catch {
                fatalError("Failed to read from: \(fileName) \(error.localizedDescription)")
            }
        }
}
