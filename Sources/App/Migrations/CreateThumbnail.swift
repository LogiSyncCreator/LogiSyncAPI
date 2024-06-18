//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent

struct CreateThumbnail: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("thumbnail")
            .id()
            .field("user_id", .string, .required)
            .field("thumbnail", .string, .required)
            .field("update_at", .date, .required)
            .field("delete", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("thumbnail").delete()
    }
}
