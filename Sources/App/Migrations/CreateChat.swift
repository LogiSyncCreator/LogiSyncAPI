//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent

struct CreateChat: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chat")
            .id()
            .field("room_id", .string, .required)
            .field("user_id", .string, .required)
            .field("body", .string, .required)
            .field("create_at", .date, .required)
            .field("mention", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chat").delete()
    }
}
