//
//  User.swift
//
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent
import struct Foundation.UUID

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    @Field(key: "company")
    var company: String
    @Field(key: "role")
    var role: String
    @Field(key: "user_Id")
    var userId: String
    @Field(key: "user_pass")
    var pass: String
    @Field(key: "phone")
    var phone: String
    @Field(key: "profile")
    var profile: String
    @Field(key: "dalete")
    var delete: Bool

    init() { }

    init(id: UUID? = nil, name: String, company: String, role: String, userId: String, pass: String, phone: String, profile: String, delete: Bool) {
        self.id = id
        self.name = name
        self.company = company
        self.role = role
        self.userId = userId
        self.pass = pass
        self.phone = phone
        self.profile = profile
        self.delete = delete
    }
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            name: self.$name.value,
            company: self.$company.value,
            role: self.$role.value,
            userId: self.$userId.value,
            pass: self.$pass.value,
            phone: self.$phone.value,
            profile: self.$profile.value,
            delete: self.$delete.value
        )
    }
}
