//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct ChatRoomDTO: Content {
    var id: UUID?
    var roomId: String?
    var userId: String?
    var mention: Bool?
    
    func toModel() -> ChatRoom {
        let model = ChatRoom()
        
        model.id = self.id
        if let roomId = self.roomId,
           let userId = self.userId,
           let mention = self.mention {
            model.roomId = roomId
            model.userId = userId
            model.mention = mention
        }
        
        return model
    }
}
