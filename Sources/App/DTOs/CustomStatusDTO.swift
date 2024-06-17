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
    
    func toModel() -> CustomStatus {
        let model = CustomStatus()
        
        model.id = self.id
        if let manager = self.manager,
           let shipper = self.shipper,
           let name = self.name,
           let delete = self.delete {
            model.manager = manager
            model.shipper = shipper
            model.name = name
            model.delete = delete
        }
        return model
    }
}


