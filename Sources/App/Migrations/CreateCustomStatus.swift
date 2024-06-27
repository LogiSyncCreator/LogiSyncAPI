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
            .field("color", .string, .required)
            .field("icon", .string, .required)
            .field("index", .int)
            .create()
        
        let onlieStatus = CustomStatus(manager: "all", shipper: "all", name: "オンライン", delete: false, color: "green", icon: "checkmark.circle.fill", index: 0)
        let offlineStatus = CustomStatus(manager: "all", shipper: "all", name: "オフライン", delete: false, color: "gray", icon: "xmark.circle", index: 1)
        
        try await onlieStatus.save(on: database)
        try await offlineStatus.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema("custom_status").delete()
    }
}
