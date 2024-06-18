//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent

struct CreateMatching: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("matching")
            .id()
            .field("manager_id", .string, .required)
            .field("shipper_id", .string, .required)
            .field("driver_id", .string, .required)
            .field("start_date", .date, .required)
            .field("address", .string, .required)
            .field("delete", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("matching").delete()
    }
}

