//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Fluent
import Vapor

struct UserDTO: Content {
    
    var id: UUID?
    var name: String?
    var company: String?
    var role: String?
    var userId: String?
    var pass: String?
    var phone: String?
    var profile: String?
    var delete: Bool?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let name = self.name,
           let company = self.company,
           let role = self.role,
           let userId = self.userId,
           let pass = self.pass,
           let phone = self.phone,
           let profile = self.profile,
           let delete = self.delete {
            model.name = name
            model.company = company
            model.role = role
            model.userId = userId
            model.pass = pass
            model.phone = phone
            model.profile = profile
            model.delete = delete
        }
        
        return model
    }
}
