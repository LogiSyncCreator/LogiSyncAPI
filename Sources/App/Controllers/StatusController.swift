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

        status.get(use: self.index)
        status.post(use: self.regist)
        status.delete(":id", use: self.delete)
        status.get("setStatus",":id",":statusId", use: self.statusUpdate)
        status.get("nowstatus",":userId", use: self.getNowStatus)
        status.get("groupstatus", ":manId", ":shipId", use: self.getGroupStatus)
        status.get("searchStatus", ":userId", use: self.getSearchUserStatus)
//        status.webSocket("now", ":id") { req, ws in
//            ws.onText { ws, st in
//                        Task {
//                            do {
//                                try await nowStatusUpdate(req: req, ws: ws, message: st)
//                            } catch {
//                                print("Error: \(error)")
//                            }
//                        }
//                    }
//        }
    }

    @Sendable
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
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
    func statusUpdate(req: Request) async throws -> NowStatusDTO {
        
        guard let userId = req.parameters.get("id") else {
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
        
        return statusModel.toDTO()
    }
    
    // nowStatusUpdate
//    func nowStatusUpdate(req: Request, ws: WebSocket, message: String) async throws {
//        guard let userId = req.parameters.get("id") else {
//            throw Abort(.badRequest, reason: "Invalid or missing user ID")
//        }
//
//        let statusModel = NowStatus(userId: userId, name: message, delete: false)
//
//        // 既存ユーザーIDの検索
//        let existingStatus = try await NowStatus.query(on: req.db).filter(\.$userId == userId).all()
//        for model in existingStatus {
//            // 存在すれば更新する
//            model.delete = true
//            try await model.save(on: req.db)
//        }
//
//        try await statusModel.save(on: req.db)
//        try await ws.send("\(userId):\(message)")
//        print("\(userId):\(message)")
//    }
    
    // get now status
//    @Sendable
//    func getNowStatus(req: Request) async throws -> NowStatusDTO {
//        
//        guard let userId = req.parameters.get("id"),
//              let status = try await NowStatus.query(on: req.db).filter(\.$userId == userId).filter(\.$delete == false).first() else {
//            throw Abort(.badRequest, reason: "Invalid or missing user ID")
//        }
//        
//        return status.toDTO()
//        
//    }
    
    // ユーザーのステータスとアイコンを検索
    @Sendable
    func getSearchUserStatus(req: Request) async throws -> [CustomStatusDTO] {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest)
        }
        
        let status = try await NowStatus.query(on: req.db).filter(\.$userId == userId).filter(\.$delete == false).first()
        
        if let status = status {
            guard let uuid = UUID(uuidString: status.statusId) else {
                throw Abort(.badRequest, reason: "Invalied statusId")
            }
            let data = try await CustomStatus.query(on: req.db).filter(\.$id == uuid).all()
            return data.map { $0.toDTO() }
        } else {
            throw Abort(.badRequest)
        }
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
            let groupStatus = try await CustomStatus.query(on: req.db).filter(\.$manager == manager).filter(\.$shipper == shipper).all()
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
        
        guard let user = try await NowStatus.query(on: req.db).filter(\.$userId == userId).first() else {
            throw Abort(.badRequest, reason: "Miss match user id.")
        }
        
        guard let statusId = UUID(uuidString: user.statusId) else {
            throw Abort(.badRequest, reason: "Miss match status id")
        }
        
        guard let status = try await CustomStatus.query(on: req.db).filter(\.$id == statusId).first() else {
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
