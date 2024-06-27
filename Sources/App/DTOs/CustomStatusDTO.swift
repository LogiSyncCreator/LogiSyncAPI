//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//
import Fluent
import Vapor

struct CustomStatusDTO: Content {
    var id: UUID?
    var manager: String?
    var shipper: String?
    var name: String?
    var delete: Bool?
    var color: String?
    var icon: String?
    var index: Int?
    
    func toModel() -> CustomStatus {
        let model = CustomStatus()
        
        model.id = self.id
        if let manager = self.manager,
           let shipper = self.shipper,
           let name = self.name,
           let delete = self.delete,
           let icon = self.icon,
           let color = self.color,
           let index = self.index {
            model.manager = manager
            model.shipper = shipper
            model.name = name
            model.delete = delete
            model.icon = icon
            model.color = color
            model.index = index
        }
        return model
    }
}


