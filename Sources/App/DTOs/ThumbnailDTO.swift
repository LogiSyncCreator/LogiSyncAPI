//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct ThumbnailDTO: Content {
    var id: UUID?
    var userId: String?
    var thumbnail: String?
    var updateAt: Date?
    var delete: Bool?
    
    func toModel() -> Thumbnail {
        let model = Thumbnail()
        
        model.id = self.id
        model.updateAt = self.updateAt
        if let userId = self.userId,
           let thumbnail = self.thumbnail,
           let delete = self.delete {
            model.userId = userId
            model.thumbnail = thumbnail
            model.delete = delete
        }
        return model
    }
}
