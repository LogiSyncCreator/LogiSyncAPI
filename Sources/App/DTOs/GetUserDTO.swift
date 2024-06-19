//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/19.
//

import Foundation
import Vapor


struct GetUserDTO: Content {
    var id: UUID?
    var name: String?
    var company: String?
    var role: String?
    var userId: String?
    var phone: String?
    var profile: String?
}

extension User {
    func toGetUserDTO() -> GetUserDTO {
        return GetUserDTO(
            id: self.id,
            name: self.name,
            company: self.company,
            role: self.role,
            userId: self.userId,
            phone: self.phone,
            profile: self.profile
        )
    }
}
