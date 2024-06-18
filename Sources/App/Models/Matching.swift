//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import struct Foundation.UUID
import Fluent

final class Matching: Model, @unchecked Sendable {
    static let schema: String = "matching"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "manager_id")
    var manager: String
    @Field(key: "shipper_id")
    var shipper: String
    @Field(key: "driver_id")
    var driver: String
    @Timestamp(key: "start_date", on: .create)
    var start: Date?
    @Field(key: "address")
    var address: String
    @Field(key: "delete")
    var delete: Bool
    
    init() {
        
    }
    
    init(id: UUID? = nil, manager: String, shipper: String, driver: String, start: Date? = nil, address: String, delete: Bool) {
        self.id = id
        self.manager = manager
        self.shipper = shipper
        self.driver = driver
        self.start = start
        self.address = address
        self.delete = delete
    }
    
    func toDTO() -> MatchingDTO {
        .init(
            id: self.id,
            manager: self.manager,
            shipper: self.shipper,
            driver: self.driver,
            start: self.start,
            address: self.address,
            delete: self.delete
        )
    }
}
