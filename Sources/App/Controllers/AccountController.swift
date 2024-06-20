//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/18.
//

import Foundation
import Fluent
import Vapor

struct AccountController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let accounts = routes.grouped("accounts")
        accounts.post("regist", use: self.register)
        accounts.post("login", use: self.login)
        accounts.delete("delete", ":userID", use: self.delete)
        accounts.get("serchid", ":userID", use: self.serchId)
        accounts.get("serchuser",":userID", use: self.getUser)
//        accounts.get(use: self.index)
    }
    
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func serchId(req: Request) async throws -> Bool {
        
        let id = req.parameters.get("userID") ?? ""
        
        guard (try await User.query(on: req.db).filter(\.$userId == id).first()) != nil else {
            return false
        }
        return true
    }
    
    @Sendable 
    func getUser(req: Request) async throws -> GetUserDTO {
        guard let userId = req.parameters.get("userID" as String) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        
        guard let user = try await User.query(on: req.db).filter(\.$userId == userId).filter(\.$delete == false).first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        return user.toGetUserDTO()
    }
    
    @Sendable
    func create(req: Request) async throws -> UserDTO {
        let user = try req.content.decode(UserDTO.self).toModel()

        try await user.save(on: req.db)
        return user.toDTO()
    }
    
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let userID = req.parameters.get("userID", as: String.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        
        guard let user = try await User.query(on: req.db).filter(\.$userId == userID).first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        try await User.query(on: req.db)
            .set(\.$delete, to: !user.delete)
            .filter(\.$userId == userID)
            .update()

        return .ok
    }
    
    @Sendable
    func login(req: Request) async throws -> UserDTO {
        let userLogin = try req.content.decode(UserLogin.self)
        let res = try await User.query(on: req.db)
            .filter(\.$userId == userLogin.username)
            .filter(\.$delete == false)
            .first()
        
        if let userDelete = res?.delete {
            if userDelete { throw Abort(.badRequest) }
        }
        
        if let user = res, try Bcrypt.verify(userLogin.password, created: user.pass) {
            return user.toDTO()
        } else {
            throw Abort(.notFound)
        }
    }
    
    @Sendable
    func register(req: Request) async throws -> HTTPStatus {
        var user = try req.content.decode(UserDTO.self)
        var passwordHash = ""
        
        // 既存ユーザーIDの検索
        if let userId = user.userId {
            let query = try await User.query(on: req.db).filter(\.$userId == userId).first()
            if query != nil {
                // 存在すればバッドリクエスト
                return .badRequest
            }
        }
        
        if let userPass = user.pass {
            passwordHash = try Bcrypt.hash(userPass)
        } else {
            print("else")
            return .badRequest
        }
         
        user.pass = passwordHash
        
        let newUser = user.toModel()
        
        do {
            try await newUser.save(on: req.db)
            return .created
        } catch {
            print("catch")
            return .badRequest
        }
    }
}

struct UserLogin: Content {
    var username: String
    var password: String
}
