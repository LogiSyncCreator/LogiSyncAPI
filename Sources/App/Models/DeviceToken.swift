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
final class DeviceToken: Model, @unchecked Sendable {
    static let schema = "device_token"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: String
    @Field(key: "token")
    var token: String
    @Timestamp(key: "update_at", on: .create)
    var updateAt: Date?

    init() {
        
    }
    
    init(id: UUID? = nil, userId: String, token: String, updateAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.token = token
        self.updateAt = updateAt
    }
    
    func toDTO() -> DeviceTokenDTO {
        .init(
            id: self.id,
            userId: self.$userId.value,
            token: self.$token.value,
            updateAt: self.updateAt
        )
    }
}
