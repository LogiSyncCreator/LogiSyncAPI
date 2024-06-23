//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/23.
//

import Fluent
import Vapor

struct DeviceTokenController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tokens = routes.grouped("token")

        tokens.get(use: self.index)
        tokens.get("user", ":userId", use: self.getToken)
        tokens.post(use: self.setToken)
        
    }

    @Sendable
    func index(req: Request) async throws -> [DeviceTokenDTO] {
        try await DeviceToken.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func getToken(req: Request) async throws -> ResponseTokenDTO {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "No input user ID.")
        }
        
        let model = try await DeviceToken.query(on: req.db).filter(\.$userId == userId).first()
        
        if let token = model?.toDTO().token,
           let updateAt = model?.toDTO().updateAt {
            let res = ResponseTokenDTO(token: token, updateAt: updateAt)
            return res
        } else {
            throw Abort(.badRequest, reason: "Not find user.")
        }
    }
    
    @Sendable
    func setToken(req: Request) async throws -> HTTPStatus {
        
        let model = try req.content.decode(DeviceTokenDTO.self).toModel()
        
        let token = try await DeviceToken.query(on: req.db).filter(\.$userId == model.userId).first()
        
        if token != nil {
            // tokenがある
            do {
                try await DeviceToken.query(on: req.db).set(\.$userId, to: model.userId).set(\.$token, to: model.token).filter(\.$userId == model.userId).update()
            } catch {
                throw Abort(.badRequest, reason: "regist token error.")
            }
            
        } else {
            // tokenがない
            try await model.save(on: req.db)
        }
        
        return .noContent
        
    }
}

struct ResponseTokenDTO: Content {
    var token: String
    var updateAt: Date
}
