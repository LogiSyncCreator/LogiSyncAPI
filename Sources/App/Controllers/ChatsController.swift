//
//  File.swift
//
//
//  Created by 広瀬友哉 on 2024/07/16.
//

import Foundation
import Fluent
import Vapor

struct ChatsController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let chats = routes.grouped("chats")
        
        chats.get("index", use: self.index)
        chats.post("send", use: self.sendMessage)
        chats.get("received", ":matchingId", use: self.receivedMessage)
        chats.post("update", use: self.updateCheck)
    }
    
    @Sendable
    func index(req: Request) async throws -> [ChatsDTO] {
        try await Chats.query(on: req.db).all().map { $0.toDTO() }
    }
    
    // 送信用
    @Sendable
    func sendMessage(req: Request) async throws -> ChatsDTO {
        let chat: requestChatMesseageDTO? = try req.content.decode(requestChatMesseageDTO.self)
        
        guard let matchingId = UUID(uuidString: chat?.matchingId ?? "") else {
            throw Abort(.badRequest, reason: "matching id is invalid.")
        }
        
        guard (try await Matching.find(matchingId, on: req.db)) != nil else {
            throw Abort(.notFound, reason: "matching is not found.")
        }
        
        guard (try await User.query(on: req.db).filter(\.$userId == chat?.sendUserId ?? "").first()) != nil else {
            throw Abort(.notFound, reason: "matching is not found.")
        }
        if let chat = chat {
            let newChat = ChatsDTO(matchingId: chat.matchingId, sendUserId: chat.sendUserId, sendMessage: chat.sendMessage).toModel()
            try await newChat.save(on: req.db)
            return newChat.toDTO()
        }  else {
            throw Abort(.badRequest, reason: "chat data is invalid.")
        }
    }
    
    // 受信
    @Sendable
    func receivedMessage(req: Request) async throws -> [responseChatDTO] {
        let matchingId = req.parameters.get("matchingId") ?? ""
        let chats = try await Chats.query(on: req.db).filter(\.$matchingId == matchingId).all()
        
        
        guard let matchingId = UUID(uuidString: matchingId) else {
            throw Abort(.badRequest, reason: "input data is invalid.")
        }
        
        guard let matching = try await Matching.find(matchingId, on: req.db) else {
            throw Abort(.badRequest, reason: "matching id is invalid.")
        }
        
        guard let driver = try await User.query(on: req.db).filter(\.$userId == matching.driver).first(),
              let shipper = try await User.query(on: req.db).filter(\.$userId == matching.shipper).first(),
              let manager = try await User.query(on: req.db).filter(\.$userId == matching.shipper).first() else {
                throw Abort(.badRequest, reason: "matching id is invalid.")
        }
        
        
        var resChat: [responseChatDTO] = []
        
        for data in chats {
            var res = responseChatDTO()
                
            if data.toDTO().sendUserId == driver.toDTO().userId {
                res.sendUserId = driver.toDTO().userId
                res.userName = driver.toDTO().name
                res.role = driver.toDTO().role
            }
            if data.toDTO().sendUserId == shipper.toDTO().userId {
                res.sendUserId = shipper.toDTO().userId
                res.userName = shipper.toDTO().name
                res.role = shipper.toDTO().role
            }
            if data.toDTO().sendUserId == manager.toDTO().userId {
                res.sendUserId = manager.toDTO().userId
                res.userName = manager.toDTO().name
                res.role = manager.toDTO().role
            }
            
            res.id = data.toDTO().id
            res.matchingId = data.toDTO().matchingId
            res.sendMessage = data.toDTO().sendMessage
            res.createAt = data.toDTO().createAt
            resChat.append(res)
        }
        
        return resChat
    }
    
    // アプデチェック
    @Sendable
    func updateCheck(req: Request) async throws -> [responseChatDTO] {
        let update: requestUpdateStateDTO = try req.content.decode(requestUpdateStateDTO.self)
        
        guard let matchingId = UUID(uuidString: update.matchingId ?? "") else {
            throw Abort(.badRequest, reason: "input data is invalid.")
        }
        
        guard let matching = try await Matching.find(matchingId, on: req.db) else {
            throw Abort(.badRequest, reason: "matching id is invalid.")
        }
        
        guard let driver = try await User.query(on: req.db).filter(\.$userId == matching.driver).first(),
              let shipper = try await User.query(on: req.db).filter(\.$userId == matching.shipper).first(),
              let manager = try await User.query(on: req.db).filter(\.$userId == matching.shipper).first() else {
                throw Abort(.badRequest, reason: "matching id is invalid.")
        }
        
        if let updateMatchingId = update.matchingId,
           let updateCheckDate = update.checkDate {
            let chats = try await Chats.query(on: req.db)
                .filter(\.$matchingId == updateMatchingId)
                .filter(\.$createAt > updateCheckDate)
                .all()
            
            var resChat: [responseChatDTO] = []
            
            for data in chats {
                var res = responseChatDTO()
                if data.createAt?.description != updateCheckDate.description {
                    
                    if data.toDTO().sendUserId == driver.toDTO().userId {
                        res.sendUserId = driver.toDTO().userId
                        res.userName = driver.toDTO().name
                        res.role = driver.toDTO().role
                    }
                    if data.toDTO().sendUserId == shipper.toDTO().userId {
                        res.sendUserId = shipper.toDTO().userId
                        res.userName = shipper.toDTO().name
                        res.role = shipper.toDTO().role
                    }
                    if data.toDTO().sendUserId == manager.toDTO().userId {
                        res.sendUserId = manager.toDTO().userId
                        res.userName = manager.toDTO().name
                        res.role = manager.toDTO().role
                    }
                    
                    res.id = data.toDTO().id
                    res.matchingId = data.toDTO().matchingId
                    res.sendMessage = data.toDTO().sendMessage
                    res.createAt = data.toDTO().createAt
                    resChat.append(res)
                }
            }
            
            return resChat
            
        } else {
            throw Abort(.badRequest, reason: "Input data is invalid")
        }
        
    }
}

struct requestChatMesseageDTO: Content {
    var matchingId: String?
    var sendUserId: String?
    var sendMessage: String?
}

struct requestUpdateStateDTO: Content {
    var matchingId: String?
    var checkDate: Date?
}

struct responseChatDTO: Content {
    var id: UUID?
    var matchingId: String?
    var sendUserId: String?
    var sendMessage: String?
    var createAt: Date?
    var userName: String?
    var role: String?
}
