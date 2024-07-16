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
        
        guard let matching = try await Matching.find(matchingId, on: req.db) else {
            throw Abort(.notFound, reason: "matching is not found.")
        }
        
        guard let user = try await User.query(on: req.db).filter(\.$userId == chat?.sendUserId ?? "").first() else {
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
    func receivedMessage(req: Request) async throws -> [ChatsDTO] {
        let matchingId = req.parameters.get("matchingId") ?? ""
        let chats = try await Chats.query(on: req.db).filter(\.$matchingId == matchingId).all()
        var resChat: [ChatsDTO] = []
        
        for data in chats {
            resChat.append(data.toDTO())
        }
        
        return resChat
    }
    
    // アプデチェック
    @Sendable
    func updateCheck(req: Request) async throws -> [ChatsDTO] {
        let update: requestUpdateStateDTO? = try req.content.decode(requestUpdateStateDTO.self)
        
        if let update = update {
            let chats = try await Chats.query(on: req.db).filter(\.$matchingId == update.matchingId ?? "").filter(\.$createAt > update.checkDate ?? Date() ).all()
            
            var resChat: [ChatsDTO] = []
            
            for data in chats {
                resChat.append(data.toDTO())
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
