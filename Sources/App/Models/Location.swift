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
final class Location: Model, @unchecked Sendable {
    static let schema = "location"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: String
    @Field(key: "longitude")
    var longitude: Double
    @Field(key: "latitude")
    var latitude: Double
    @Timestamp(key: "create_at", on: .create)
    var createAt: Date?
    @Field(key: "status")
    var status: String
    
    init() {
        
    }

    init(id: UUID? = nil, userId: String, longitude: Double, latitude: Double, createAt: Date? = nil, status: String) {
        self.id = id
        self.userId = userId
        self.longitude = longitude
        self.latitude = latitude
        self.createAt = createAt
        self.status = status
    }
    
    func toDTO() -> LocationDTO {
        .init(id: self.id,
              userId: self.$userId.value,
              longitude: self.$longitude.value,
              latitude: self.$latitude.value,
              createAt: self.createAt,
              status: self.$status.value)
    }
}

