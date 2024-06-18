//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct ChatDTO: Content {
    var id: UUID?
    var roomId: String?
    var userId: String?
    var body: String?
    var createAt: Date?
    var mention: String?
    
    func toModel() -> Chat {
        let model = Chat()
        
        model.id = self.id
        model.createAt = self.createAt
        if let roomId = self.roomId,
           let userId = self.userId,
           let body = self.body,
           let mention = self.mention {
            model.roomId = roomId
            model.userId = userId
            model.body = body
            model.mention = mention
        }
        return model
    }
}
