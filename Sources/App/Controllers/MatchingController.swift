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

        todos.post(use: self.regist)
        todos.get("cancel", ":uuid", use: self.cancel)
        todos.post("group", use: self.getMatching)
        
    }
    
    // 登録
    @Sendable
    func regist(req: Request) async throws -> MatchingDTO {
        let matching = try req.content.decode(MatchingDTO.self).toModel()
        
        print(try req.content.decode(MatchingDTO.self).toModel())
        
        try await matching.save(on: req.db)
        
        let status = try await req.client.post(URI(stringLiteral: "http://\(EnvData().ip):\(EnvData().port)/push/matchingregist"), content: matching.toDTO())
        
        print("push: \(status.status)")
        
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
        
        let matching = try await Matching.find(uuid, on: req.db)
        
        let status = try await req.client.post(URI(stringLiteral: "http://\(EnvData().ip):\(EnvData().port)/push/matchingcancel"), content: matching?.toDTO() ?? MatchingDTO())
        
        print("push: \(status.status)")
        
        return .noContent
    }
    
    // ユーザIDで取得
    @Sendable
    func getMatching(req: Request) async throws -> [ResponseMatchingGroup] {
        let matching = try req.content.decode(RequestMatchingGroupDTO.self)
        let matchings = try await Matching.query(on: req.db)
            .group(.or) { orGroup in
                orGroup.filter(\.$manager == matching.manager ?? "")
                    .filter(\.$driver == matching.driver ?? "")
                    .filter(\.$shipper == matching.shipper ?? "")
            }.filter(\.$delete == false).sort(\.$start)
            .all()
        
        var res: [ResponseMatchingGroup] = []
        var index: Int = 0
        
        for match in matchings {
            var user = MatchingUserData()
            
            user.driver = try await User.query(on: req.db)
                .filter(\.$userId == match.driver).first()?.toResDTO()
            user.manager = try await User.query(on: req.db)
                .filter(\.$userId == match.manager).first()?.toResDTO()
            user.shipper = try await User.query(on: req.db)
                .filter(\.$userId == match.shipper).first()?.toResDTO()
            
            res.append(ResponseMatchingGroup(index: index, matching: MatchingGroup(id: match.id?.uuidString ?? "", manager: match.manager, shipper: match.shipper, driver: match.driver, address: match.address, start: match.start ?? Date()), user: user))
            
            index += 1
        }
        
        return res
    }
}

struct RequestMatchingGroupDTO: Content {
    var manager: String?
    var driver: String?
    var shipper: String?
}

struct MatchingGroup: Content {
    var id: String
    var manager: String
    var shipper: String
    var driver: String
    var address: String
    var start: Date
}

struct ResponseMatchingGroup: Content {
    var index: Int
    var matching: MatchingGroup?
    var user: MatchingUserData?
}

struct MatchingUserData: Content {
    var driver: UserDTO?
    var manager: UserDTO?
    var shipper: UserDTO?
}
