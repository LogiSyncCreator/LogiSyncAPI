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
final class Thumbnail: Model, @unchecked Sendable {
    static let schema = "thumbnail"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: String
    @Field(key: "thumbnail")
    var thumbnail: String
    @Timestamp(key: "update_at", on: .create)
    var updateAt: Date?
    @Field(key: "delete")
    var delete: Bool

    init() {
        
    }
    
    init(id: UUID? = nil, userId: String, thumbnail: String, updateAt: Date? = nil, delete: Bool) {
        self.id = id
        self.userId = userId
        self.thumbnail = thumbnail
        self.updateAt = updateAt
        self.delete = delete
    }
    
    func toDTO() -> ThumbnailDTO {
        .init(
            id: self.id,
            userId: self.$userId.value,
            thumbnail: self.$thumbnail.value,
            updateAt: self.updateAt,
            delete: self.$delete.value
        )
    }
}
