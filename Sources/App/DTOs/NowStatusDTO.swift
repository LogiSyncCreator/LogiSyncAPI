//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct NowStatusDTO: Content {
    var id: UUID?
    var userId: String?
    var statusId: String?
    var createAt: Date?
    var delete: Bool?
    
    func toModel() -> NowStatus {
        let model = NowStatus()
        
        model.id = self.id
        model.createAt = self.createAt
        if let userId = self.userId,
           let statusId = self.statusId,
           let delete = self.delete {
            model.userId = userId
            model.statusId = statusId
            model.delete = delete
        }
        return model
    }
}
