//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("company", .string, .required)
            .field("role", .string, .required)
            .field("user_Id", .string, .required)
            .field("user_pass", .string, .required)
            .field("phone", .string, .required)
            .field("profile", .string, .required)
            .field("delete", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
