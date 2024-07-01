//
//  File.swift
//  
//
//  Created by 広瀬友哉 on 2024/06/26.
//

import Fluent
import Vapor
import APNSCore

struct PushController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("push")

        todos.get(use: self.index)
        todos.get("test",":userId", use: self.testNotificationUsersAllDevaice)
        todos.get("notificationstatus",":hostId",":statusId", use: self.notificationStatus)
        todos.post("matchingregist", use: self.registNotificationMatching)
        todos.post("matchingcancel", use: self.cancelNotificationMatching)
        todos.post(use: self.updateDeviceToken)
        todos.delete("deletetoken", ":token", use: self.delete)
    }

    @Sendable
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        let todo = try req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    // トークンの削除
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let token = req.parameters.get("token") else {
            throw Abort(.badRequest, reason: "token is invalid")
        }
        
        try await DeviceToken.query(on: req.db).filter(\.$token == token).delete()
        
        return .noContent
    }
    
    @Sendable
    func test(req: Request) async throws -> HTTPStatus {
        
        let payload = Payload(title: "test", body: "push", like: "cc")
        
        let alert = APNSAlertNotification(
            alert: .init(
                title: .raw("LogiSync"),
                body: .raw("PushControllerからこんにちは")
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: "com.nanaSoft.LogiSync",
            payload: payload,
            sound: .default
        )
        
        try await req.apns.client.sendAlertNotification(alert, deviceToken: "a3ac563182d42bb7f99e105c08642e30815649669dd442216bb2177cc6f98f4a")
        
        return .ok
    }
    
    /// DeviceTokenの更新API
    /// - リクエストの受信
    /// - ユーザーIDの照合
    /// - 登録済みの確認
    /// - 登録
    @Sendable
    func updateDeviceToken(req: Request) async throws -> HTTPStatus {
        let reqToken = try req.content.decode(DeviceTokenDTO.self).toModel()
        
        guard (try await User.query(on: req.db).filter(\.$userId == reqToken.userId).first()) != nil else {
            throw Abort(.badRequest, reason: "Not found user id.")
        }
        
        if (try await DeviceToken.query(on: req.db).filter(\.$token == reqToken.token).first()) != nil {
            if (try await DeviceToken.query(on: req.db).filter(\.$token == reqToken.token).filter(\.$userId != reqToken.userId).first()) != nil {
                try await DeviceToken.query(on: req.db).set(\.$userId, to: reqToken.userId).filter(\.$token == reqToken.token).filter(\.$userId != reqToken.userId).update()
                return .ok
            }
            throw Abort(.badRequest, reason: "Registered device token.")
        }
        
        try await reqToken.save(on: req.db)
        
        return .ok
    }
    
    /// ユーザーの持つすべての登録端末に通知を送信
    /// - parametars
    ///     - userId
    /// - 手順
    ///     - パラメータの確認
    ///     - データ取り出し
    ///     - データのnullチェック
    ///     - 通知の送信
    @Sendable
    func testNotificationUsersAllDevaice(req: Request) async throws -> HTTPStatus {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "Not input UserId.")
        }
        
        let userTokens = try await DeviceToken.query(on: req.db).filter(\.$userId == userId).all()
        
        if userTokens.isEmpty {
            throw Abort(.badRequest, reason: "Invalid user ID.")
        } else {
            for data in userTokens {
                let payload = Payload(title: "テスト送信", body: "テストだよ", like: "テスト")
                let alert = APNSAlertNotification(
                    alert: .init(
                        title: .raw("LogiSync"),
                        body: .raw("テスト送信です")
                    ),
                    expiration: .immediately,
                    priority: .immediately,
                    topic: "com.nanaSoft.LogiSync",
                    payload: payload,
                    sound: .default
                )
                try await req.apns.client.sendAlertNotification(alert, deviceToken: data.token)
            }
            return .ok
        }
    }
    
    /// マッチング登録
    /// - parametars
    ///     - マッチングID
    @Sendable
    func registNotificationMatching(req: Request) async throws -> HTTPStatus {
        let matching = try req.content.decode(MatchingDTO.self)
        
        let tokens = try await DeviceToken.query(on: req.db).group(.or) { token in
            token.filter(\.$userId == matching.driver ?? "")
            token.filter(\.$userId == matching.shipper ?? "")
            token.filter(\.$userId == matching.manager ?? "")
        }.all()
        
        guard let driver = try await User.query(on: req.db).filter(\.$userId == matching.driver ?? "").first() else {
            throw Abort(.badRequest, reason: "Driver ID is invalid.")
        }
        guard let shipper = try await User.query(on: req.db).filter(\.$userId == matching.shipper ?? "").first() else {
            throw Abort(.badRequest, reason: "Shipper ID is invalid.")
        }
        
        let payload = CommonPayload(userId: "", status: "", mode: "matching")
        
        let alert = APNSAlertNotification(
            alert: .init(
                title: .raw("LogiSync"),
                body: .raw("\(driver.name)さんと\(shipper.name)さんがマッチングされました")
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: "com.nanaSoft.LogiSync",
            payload: payload,
            sound: .default
        )
        
        for token in tokens {
            
            try await req.apns.client.sendAlertNotification(alert, deviceToken: token.token)
            
            let back = APNSBackgroundNotification(expiration: .immediately, topic:  "com.nanaSoft.LogiSync", payload: matching)
            
            try await req.apns.client.sendBackgroundNotification(back, deviceToken: token.token)
            
        }
        
        
        return .ok
    }
    
    /// マッチング解除通知
    /// - parametars
    ///     - shipper name
    ///     - driver name
    @Sendable
    func cancelNotificationMatching(req: Request) async throws -> HTTPStatus {
        
        let matching = try req.content.decode(MatchingDTO.self)
        
        guard let driver = try await User.query(on: req.db).filter(\.$userId == matching.driver ?? "").first() else {
            throw Abort(.badRequest, reason: "Driver ID is invalid.")
        }
        guard let shipper = try await User.query(on: req.db).filter(\.$userId == matching.shipper ?? "").first() else {
            throw Abort(.badRequest, reason: "Shipper ID is invalid.")
        }
        
        let tokens = try await DeviceToken.query(on: req.db).group(.or) { token in
            token.filter(\.$userId == matching.driver ?? "")
            token.filter(\.$userId == matching.shipper ?? "")
            token.filter(\.$userId == matching.manager ?? "")
        }.all()
        
        let payload = CommonPayload(userId: "", status: "", mode: "matching")
        
        let alert = APNSAlertNotification(
            alert: .init(
                title: .raw("LogiSync"),
                body: .raw("\(driver.name)さんと\(shipper.name)さんのマッチングが終了しました")
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: "com.nanaSoft.LogiSync",
            payload: payload,
            sound: .default
        )
        
        for token in tokens {
            
            try await req.apns.client.sendAlertNotification(alert, deviceToken: token.token)
            
            let back = APNSBackgroundNotification(expiration: .immediately, topic:  "com.nanaSoft.LogiSync", payload: payload)
            
            try await req.apns.client.sendBackgroundNotification(back, deviceToken: token.token)
            
        }
        
        return .ok
    }

    // ステータスの変更を伝える
    @Sendable
    func notificationStatus(req: Request) async throws -> HTTPStatus {
        guard let host = req.parameters.get("hostId") else {
            req.logger.error("hostId not provided")
            return .badRequest
        }
        guard let status = req.parameters.get("statusId") else {
            req.logger.error("statusId not provided")
            return .badRequest
        }
        
        guard let statusUuid = UUID(uuidString: status) ,let statusData = try await CustomStatus.find(statusUuid, on: req.db) else {
            req.logger.error("statusId is invalid")
            return .badRequest
        }
        
        guard let hostUser = try await User.query(on: req.db).filter(\.$userId == host).first() else {
            req.logger.error("Invalid hostId: \(host)")
            throw Abort(.badRequest, reason: "UserId is invalid.")
        }
        
        let receiverUsers = try await Matching.query(on: req.db).group(.or) { group in
            group.filter(\.$driver == hostUser.userId)
                 .filter(\.$shipper == hostUser.userId)
                 .filter(\.$manager == hostUser.userId)
        }.filter(\.$delete == false).all()
        
        req.logger.info("Found \(receiverUsers.count) receiver users")

        var tokens: [DeviceTokenDTO] = []
        
        for user in receiverUsers {
            let token = try await DeviceToken.query(on: req.db).group(.or) { group in
                group.filter(\.$userId == user.driver)
                     .filter(\.$userId == user.manager)
                     .filter(\.$userId == user.shipper)
            }.all()
            for data in token {
                tokens.append(data.toDTO())
            }
        }
        
        req.logger.info("Found \(tokens.count) tokens")

        if let hostUserName = hostUser.toDTO().name,
           let hostUserId = hostUser.toDTO().userId {
            if tokens.isEmpty {
                req.logger.info("No tokens found")
            } else {
                req.logger.info("Tokens found, sending notifications")
            }
            
            
            let payload = StatusPayload(userId: hostUserId, status: status, mode: "status")
            
            let alert = APNSAlertNotification(
                alert: .init(
                    title: .raw("LogiSync"),
                    body: .raw("\(hostUserName)が\(statusData.name)になりました")
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: "com.nanaSoft.LogiSync",
                payload: payload,
                sound: .default
            )
            
            for token in tokens {
                // アンラップ
                if let userId = token.userId,
                   let token = token.token {
                    // ホスト以外へ通知
                    if userId != hostUser.userId {
                        do{
                            try await req.apns.client.sendAlertNotification(alert, deviceToken: token)
                        } catch {
                            print("TokenError: \(token)")
                        }
                    } // ホスト以外へ通知
                    do {
                        let back = APNSBackgroundNotification(expiration: .immediately, topic: "com.nanaSoft.LogiSync", payload: payload)
                        
                        try await req.apns.client.sendBackgroundNotification(back, deviceToken: token)
                    } catch {
                        print("TokenError: \(token)")
                    }
                } // アンラップ
            }
            
            return .ok
            
        } else {
            req.logger.error("Host user name not found")
        }
        
        return .badRequest
    }
    
    // プッシュ通知とバックグラウンド通知の使い分け
    // プッシュ通知で連絡
    // バックグラウンドでデータをもらう
    // 値を更新する系統はPush
    // チャットは両方使うなどパターンはありそう
}

struct StatusPayload: Codable {
    var userId: String
    var status: String
    var mode: String
}

struct CommonPayload: Codable {
    var userId: String
    var status: String
    var mode: String
}
