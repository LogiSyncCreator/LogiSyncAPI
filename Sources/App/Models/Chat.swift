//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Chat: Model, @unchecked Sendable {
    static let schema = "chat"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "room_id")
    var roomId: String
    @Field(key: "user_id")
    var userId: String
    @Field(key: "body")
    var body: String
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    @Field(key: "mention")
    var mention: String

    init() {
        
    }
    
    init(id: UUID? = nil, roomId: String, userId: String, body: String, createAt: Date? = nil, mention: String) {
        self.id = id
        self.roomId = roomId
        self.userId = userId
        self.body = body
        self.createAt = createAt
        self.mention = mention
    }
    
    func toDTO() -> ChatDTO {
        .init(
              id: self.id,
              roomId: self.$roomId.value,
              userId: self.$userId.value,
              body: self.$body.value,
              createAt: self.createAt,
              mention: self.$mention.value
        )
    }
}

