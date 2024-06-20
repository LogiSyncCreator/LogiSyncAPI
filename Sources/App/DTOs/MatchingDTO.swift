//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct MatchingDTO: Content {
    var id: UUID?
    var manager: String?
    var shipper: String?
    var driver: String?
    var start: Date?
    var address: String?    // 目的地
    var delete: Bool?
    
    func toModel() -> Matching {
        let model = Matching()
        
        model.id = self.id
        model.start = self.start
        if let manager = self.manager,
           let shipper = self.shipper,
           let driver = self.driver,
           let address = self.address,
           let delete = self.delete {
            model.manager = manager
            model.shipper = shipper
            model.driver = driver
            model.address = address
            model.delete = delete
        }
        
        return model
    }
}
