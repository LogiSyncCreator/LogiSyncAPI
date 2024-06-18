//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent

struct CreateDeviceToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("device_token")
            .id()
            .field("user_id", .string, .required)
            .field("token", .string, .required)
            .field("update_at", .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("device_token").delete()
    }
}
