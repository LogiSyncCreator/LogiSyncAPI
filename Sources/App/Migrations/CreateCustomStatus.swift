//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent

struct CreateCustomStatus: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("custom_status")
            .id()
            .field("manager_id", .string, .required)
            .field("shipper_id", .string, .required)
            .field("name", .string, .required)
            .field("delete", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("custom_status").delete()
    }
}
