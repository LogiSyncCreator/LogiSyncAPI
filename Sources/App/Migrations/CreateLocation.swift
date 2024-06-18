//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent

struct CreateLocation: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("location")
            .id()
            .field("user_id", .string, .required)
            .field("longitude", .double, .required)
            .field("latitude", .double, .required)
            .field("create_at", .date, .required)
            .field("status", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("location").delete()
    }
}
