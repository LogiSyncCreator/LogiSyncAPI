//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/19.
//

import Foundation
import Fluent
import Vapor

struct ThumbnailController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let thum = routes.grouped("thumbnails")

        thum.get(use: self.index)
        thum.post("regist",use: self.regist)
        thum.get("getThumb",":userID", use: self.getThumbnail)
        thum.delete("delete",":userID", use: self.delete)
    }

    @Sendable
    func index(req: Request) async throws -> [ThumbnailDTO] {
        try await Thumbnail.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func getThumbnail(req: Request) async throws -> String {
        guard let userId = req.parameters.get("userID" as String) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        
        guard let thumb = try await Thumbnail.query(on: req.db).filter(\.$userId == userId).filter(\.$delete == false).first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        return thumb.thumbnail
    }

    @Sendable
    func regist(req: Request) async throws -> ThumbnailDTO {
        let thum = try req.content.decode(ThumbnailDTO.self).toModel()
        
        // 既存ユーザーIDの検索
        let query = try await Thumbnail.query(on: req.db).filter(\.$userId == thum.userId).first()
        if query != nil {
            // 存在すれば更新する
            try await Thumbnail.query(on: req.db).set(\.$delete, to: true).filter(\.$userId == thum.userId).update()
        }

        try await thum.save(on: req.db)
        return thum.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let userId = req.parameters.get("userID" as String) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        
        try await Thumbnail.query(on: req.db).set(\.$delete, to: true).filter(\.$userId == userId).update()
        
        return .noContent
    }
}
