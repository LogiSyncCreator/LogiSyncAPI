//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/23.
//

import Foundation
import Fluent
import Vapor

struct LocationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let location = routes.grouped("locations")

        location.get("index",use: self.index)
        location.post(use: self.regist)
        location.delete(":userId", use: self.delete)
        location.get(":userId", use: self.getLocation)
        location.delete("deletemylocation", ":UUID", use: self.deleteLocation)
    }

    @Sendable
    func index(req: Request) async throws -> [LocationDTO] {
        try await Location.query(on: req.db).all().map { $0.toDTO() }
    }
    
    // 追加
    @Sendable
    func regist(req: Request) async throws -> LocationDTO {
        let lon = try req.content.decode(LocationDTO.self).toModel()
        try await lon.save(on: req.db)
        return lon.toDTO()
    }
    // 全数削除
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "No input userID.")
        }
        
        let model = try await Location.query(on: req.db).filter(\.$userId == userId).all()
        
        try await model.delete(on: req.db)
        
        return .noContent
    }
    // 検索
    @Sendable
    func getLocation(req: Request) async throws -> [LocationDTO] {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "No input userID.")
        }
        
        return try await Location.query(on: req.db).filter(\.$userId == userId).all().map {
            $0.toDTO()
        }
    }
    
    // 任意削除
    @Sendable
    func deleteLocation(req: Request) async throws -> HTTPStatus {
        guard let uuidString = req.parameters.get("UUID") else {
            throw Abort(.badRequest, reason: "No input UUID.")
        }
        
        guard let uuid = UUID(uuidString: uuidString) else {
            throw Abort(.badRequest, reason: "Input UUID is invalid.")
        }
        
        let model = try await Location.find(uuid, on: req.db)
        
        try await model?.delete(on: req.db)
        
        return .noContent
        
    }

}
