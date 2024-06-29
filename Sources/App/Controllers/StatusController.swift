//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/21.
//

import Foundation
import Fluent
import Vapor

struct StatusController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let status = routes.grouped("status")

        status.post(use: self.regist)
        status.delete(":id", use: self.delete)
        status.get("nowstatus",":userId", use: self.getNowStatus)
        status.get("groupstatus", ":manId", ":shipId", use: self.getGroupStatus)
        status.get("setstatus", ":userId", ":statusId", use: self.setStatus)
    }
    
    // customStatusの新規登録
    @Sendable
    func regist(req: Request) async throws -> CustomStatusDTO {
        let status = try req.content.decode(CustomStatusDTO.self).toModel()
        
        try await status.save(on: req.db)
        return status.toDTO()
    }
    
    // customStatusの論理削除
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        
        guard let statusId = req.parameters.get("id"),
              let uuid = UUID(uuidString: statusId) else {
            throw Abort(.badRequest, reason: "Invalid or missing status ID")
        }
                
        
        do{
            try await CustomStatus.query(on: req.db).set(\.$delete, to: true).filter(\.$id == uuid).update()
            return .noContent   // 204
        } catch {
            throw Abort(.internalServerError, reason: "Failed to update status")
        }
        
    }
    
    @Sendable
    func setStatus(req: Request) async throws -> ResponseNowStatusDTO {
        
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        
        
        guard let statusId = req.parameters.get("statusId") else {
            throw Abort(.badRequest, reason: "Invalid or missing msg")
        }
            
        
        let statusModel = NowStatus(userId: userId, statusId: statusId, delete: false)
        
        
        // 既存ユーザーIDの検索
        let existingStatus = try await NowStatus.query(on: req.db).filter(\.$userId == userId).all()
        
        for model in existingStatus {
            // 存在すれば更新する
            model.delete = true
            try await model.save(on: req.db)
        }

        try await statusModel.save(on: req.db)
        
        guard let user = try await NowStatus.query(on: req.db).filter(\.$userId == userId).filter(\.$delete == false).first() else {
            throw Abort(.badRequest, reason: "Miss match user id.")
        }
        
        guard let statusId = UUID(uuidString: user.statusId) else {
            throw Abort(.badRequest, reason: "Miss match status id")
        }
        
        guard let status = try await CustomStatus.query(on: req.db).filter(\.$id == statusId).filter(\.$delete == false).first() else {
            throw Abort(.badRequest, reason: "Miss match status id.")
        }
        
        let res = ResponseNowStatusDTO(id: user.id, userId: userId, statusId: user.statusId, name: status.name, color: status.color, icon: status.icon, delete: status.delete)
        
        return res
    }

    
    @Sendable
    func getGroupStatus(req: Request) async throws -> [CustomStatusDTO] {
        
        guard let manager = req.parameters.get("manId"),
              let shipper = req.parameters.get("shipId")
               else {
            throw Abort(.badRequest, reason: "Invalid or missing id ")
        }
        
        if manager == "all" {
            do {
                let groupStatus = try await CustomStatus.query(on: req.db).filter(\.$manager == "all").filter(\.$manager == manager).filter(\.$shipper == shipper).all()
                return groupStatus.map { $0.toDTO() }
            } catch {
                throw Abort(.badRequest, reason: "Invalid or miss match id")
            }
        }
        
        do {
            let groupStatus = try await CustomStatus.query(on: req.db).filter(\.$manager == manager).filter(\.$shipper == shipper).filter(\.$delete == false).all()
            return groupStatus.map { $0.toDTO() }
        } catch {
            throw Abort(.badRequest, reason: "Invalid or miss match id")
        }
        
        
    }
    
    // 現在のステータスを取得する
    @Sendable
    func getNowStatus(req: Request) async throws -> ResponseNowStatusDTO {
        // userId , statusId
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "No input user id.")
        }
        
        guard let user = try await NowStatus.query(on: req.db).filter(\.$userId == userId).filter(\.$delete == false).first() else {
            throw Abort(.badRequest, reason: "Miss match user id.")
        }
        
        guard let statusId = UUID(uuidString: user.statusId) else {
            throw Abort(.badRequest, reason: "Miss match status id")
        }
        
        guard let status = try await CustomStatus.query(on: req.db).filter(\.$id == statusId).filter(\.$delete == false).first() else {
            throw Abort(.badRequest, reason: "Miss match status id.")
        }
        
        
        let res = ResponseNowStatusDTO(id: user.id, userId: user.userId, statusId: user.statusId, name: status.name, color: status.color, icon: status.icon, delete: status.delete)
        
        return res
                
    }
}

struct ResponseNowStatusDTO: Content {
    var id: UUID?
    var userId: String?
    var statusId: String?
    var name: String?
    var color: String?
    var icon: String?
    var delete: Bool?
}
