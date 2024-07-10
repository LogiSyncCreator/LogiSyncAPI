//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct DeviceTokenDTO: Content, Hashable {
    var id: UUID?
    var userId: String?
    var token: String?
    var updateAt: Date?
    
    func toModel() -> DeviceToken {
        let model = DeviceToken()
        
        model.id = self.id
        model.updateAt = self.updateAt
        if let userId = self.userId,
           let token = self.token {
            model.userId = userId
            model.token = token
        }
        return model
    }
    
    static func == (lhs: DeviceTokenDTO, rhs: DeviceTokenDTO) -> Bool {
        return lhs.token == rhs.token
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(token)
    }
}
