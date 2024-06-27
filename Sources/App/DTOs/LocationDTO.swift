//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent
import Vapor

struct LocationDTO: Content {
    var id: UUID?
    var userId: String?
    var longitude: Double?
    var latitude: Double?
    var createAt: Date?
    var status: String?
    var delete: Bool?
    
    func toModel() -> Location {
        let model = Location()
        
        model.id = self.id
        model.createAt = self.createAt
        if let userId = self.userId,
           let longitude = self.longitude,
           let latitude = self.latitude,
           let status = self.status,
           let delete = self.delete {
            model.userId = userId
            model.longitude = longitude
            model.latitude = latitude
            model.status = status
            model.delete = delete
        }
        return model
    }
}

