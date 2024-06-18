//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent

struct CreateNowStatus: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("now_status")
            .id()
            .field("user_id", .string, .required)
            .field("status_name", .string, .required)
            .field("update_at", .date, .required)
            .field("delete", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("now_status").delete()
    }
}
