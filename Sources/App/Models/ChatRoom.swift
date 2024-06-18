//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//
import Foundation
import struct Foundation.UUID
import Fluent

final class ChatRoom: Model, @unchecked Sendable {
    static let schema: String = "chat_room"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "room_id")
    var roomId: String
    @Field(key: "user_id")
    var userId: String
    
    init() {
        
    }
    
    init(id: UUID? = nil, roomId: String, userId: String) {
        self.id = id
        self.roomId = roomId
        self.userId = userId
    }
    
    func toDTO() -> ChatRoomDTO {
        .init(
            id: self.id,
            roomId: self.$roomId.value,
            userId: self.$userId.value
        )
    }
    
}
