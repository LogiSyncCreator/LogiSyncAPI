//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/07/16.
//

import Foundation
import Fluent
final class Chats: Model, @unchecked Sendable {
    static let schema: String = "chats"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "matching_id")
    var matchingId: String
    @Field(key: "send_user")
    var sendUserId: String
    @Field(key: "send_message")
    var sendMessage: String
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    
    init() {
        
    }
    
    init(id: UUID? = nil, matchingId: String, sendUserId: String, sendMessage: String, createAt: Date? = nil) {
        self.id = id
        self.matchingId = matchingId
        self.sendUserId = sendUserId
        self.sendMessage = sendMessage
        self.createAt = createAt
    }
    
    func toDTO() -> ChatsDTO {
        .init(
            id: self.id,
            matchingId: self.$matchingId.value,
            sendUserId: self.$sendUserId.value,
            sendMessage: self.$sendMessage.value,
            createAt: self.createAt
        )
    }
    
}
