//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent

struct CreateChats_2: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chats")
            .id()
            .field("matching_id", .string, .required)
            .field("send_user", .string, .required)
            .field("send_message", .string, .required)
            .field("create_at", .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chats").delete()
    }
}
