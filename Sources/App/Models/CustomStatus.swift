//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent
import struct Foundation.UUID

final class CustomStatus: Model, @unchecked Sendable {
    static let schema: String = "custom_status"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "manager_id")
    var manager: String
    @Field(key: "shipper_id")
    var shipper: String
    @Field(key: "name")
    var name: String
    @Field(key: "delete")
    var delete: Bool
    @Field(key: "color")
    var color: String
    @Field(key: "icon")
    var icon: String
    @Field(key: "index")
    var index: Int
    init() {
        
    }
    
    init(id: UUID? = nil, manager: String, shipper: String, name: String, delete: Bool, color: String, icon: String, index: Int) {
        self.id = id
        self.manager = manager
        self.shipper = shipper
        self.name = name
        self.delete = delete
        self.color = color
        self.icon = icon
        self.index = index
    }
    
    func toDTO() -> CustomStatusDTO {
        .init(
            id: self.id,
            manager: self.$manager.value,
            shipper: self.$shipper.value,
            name: self.$name.value,
            delete: self.$delete.value,
            color: self.$color.value,
            icon: self.$icon.value,
            index: self.$index.value
        )
    }
}
