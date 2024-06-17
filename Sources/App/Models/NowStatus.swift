//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent
import struct Foundation.UUID
import Foundation

final class NowStatus: Model, @unchecked Sendable {
    static let schema: String = "now_status"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user_id")
    var userId: String
    @Field(key: "status_name")
    var name: String
    @Timestamp(key: "update_at", on: .create)
    var createAt: Date?
    @Field(key: "delete")
    var delete: Bool
    
    init() {
        
    }
    
    init(id: UUID? = nil, userId: String, name: String, createAt: Date? = nil, delete: Bool) {
        self.id = id
        self.userId = userId
        self.name = name
        self.createAt = createAt
        self.delete = delete
    }
    
    func toDTO() -> NowStatusDTO {
        .init(
            id: self.id,
            userId: self.$userId.value,
            name: self.$name.value,
            createAt: self.createAt,
            delete: self.$delete.value
        )
    }
    
}
