//
//  Prospect.swift
//  HotProspects
//
//  Created by Gavin Butler on 21-09-2020.
//

import SwiftUI

enum PersistenceType {
    case userDefaults, fileManager
}

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    var createdDate = Date()
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    static let saveKey = "SavedData"    //For userDefaults saving
    static let fileName = "HotProspectsSavedData"   //For File Manager saving
    
    let persistenceType: PersistenceType = .fileManager
    
    init() {
        self.people = []
        
        switch self.persistenceType {
        case .userDefaults:
            if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
                if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                    self.people = decoded
                    return
                }
            }
        case .fileManager:
            //Create a blank file if the file doesn't yet exist
            if !FileManager.fileAlreadyExists(Self.fileName), let encodedProspects = try? JSONEncoder().encode(self.people) {
                FileManager.writeTo(content: encodedProspects, fileName: Self.fileName)
            }
            
            let peopleData = FileManager.dataContentsOf(fileName: Self.fileName)
            let decoder = JSONDecoder()
            if let decodedPeople = try? decoder.decode([Prospect].self, from: peopleData) {
                self.people = decodedPeople
                return
            }
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save() {
        switch self.persistenceType {
        case .userDefaults:
            if let encoded = try? JSONEncoder().encode(people) {
                UserDefaults.standard.set(encoded, forKey: Self.saveKey)
            }
        case .fileManager:
            let encoder = JSONEncoder()
            if let encodedProspects = try? encoder.encode(self.people) {
                FileManager.writeDataTo(content: encodedProspects, fileName: Self.fileName)
            }
        }
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
