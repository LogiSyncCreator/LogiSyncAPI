//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/21.
//

import Foundation
import Fluent
import Vapor

struct MatchingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("matching")

        todos.get(use: self.index)
        todos.post(use: self.regist)
        todos.get("cancel", ":uuid", use: self.cancel)
        todos.post("group", use: self.getMatching)
        
    }

    @Sendable
    func index(req: Request) async throws -> [MatchingDTO] {
        try await Matching.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        let todo = try req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
    
    // 登録
    @Sendable
    func regist(req: Request) async throws -> MatchingDTO {
        let matching = try req.content.decode(MatchingDTO.self).toModel()
        
        try await matching.save(on: req.db)
        return matching.toDTO()
    }
    
    // 解除
    @Sendable
    func cancel(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("uuid"),
              let uuid = UUID(uuidString: id) else {
            throw Abort(.badRequest)
        }
        
        try await Matching.query(on: req.db).set(\.$delete, to: true).filter(\.$id == uuid).update()
        
        return .noContent
    }
    
    // ユーザIDで取得
    @Sendable
    func getMatching(req: Request) async throws -> [MatchingDTO] {
        let matching = try req.content.decode(MatchingGroupDTO.self)
        return try await Matching.query(on: req.db)
            .group(.or) { orGroup in
                orGroup.filter(\.$manager == matching.manager)
                    .filter(\.$driver == matching.driver)
                    .filter(\.$shipper == matching.shipper)
            }.sort(\.$start)
            .all().map {
                $0.toDTO()
            }
    }
}

struct MatchingGroupDTO: Content {
    var manager: String
    var driver: String
    var shipper: String
}
