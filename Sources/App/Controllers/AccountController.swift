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
        accounts.get(use: self.index)
    }
    
    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func create(req: Request) async throws -> UserDTO {
        let user = try req.content.decode(UserDTO.self).toModel()

        try await user.save(on: req.db)
        return user.toDTO()
    }
    
    
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await user.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func login(req: Request) async throws -> UserDTO {
        let userLogin = try req.content.decode(UserLogin.self)
        let res = try await User.query(on: req.db)
            .filter(\.$userId == userLogin.username)
            .first()
        
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
