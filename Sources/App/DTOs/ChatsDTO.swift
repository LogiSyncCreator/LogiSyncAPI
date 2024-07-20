//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/07/16.
//

import Foundation
import Fluent
import Vapor

struct ChatsDTO: Content {
    var id: UUID?
    var matchingId: String?
    var sendUserId: String?
    var sendMessage: String?
    var createAt: Date?
    
    func toModel() -> Chats {
        let model = Chats()
        
        model.id = self.id
        model.createAt = self.createAt
        
        if let matchingId = self.matchingId,
           let sendUserId = self.sendUserId,
           let sendMessage = self.sendMessage {
            model.matchingId = matchingId
            model.sendUserId = sendUserId
            model.sendMessage = sendMessage
        }
        return model
    }
}
