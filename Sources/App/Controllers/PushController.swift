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
        todos.get("notificationstatus",":hostId",":receiverId",":status", use: self.notificationStatus)
        todos.post(use: self.updateDeviceToken)
        todos.group(":todoID") { todo in
            todo.delete(use: self.delete)
        }
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

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
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
        
        if let deviceToken = try await DeviceToken.query(on: req.db).filter(\.$token == reqToken.token).first() {
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
    
    // プッシュ通知とバックグラウンド通知の使い分け
    // プッシュ通知で連絡
    // バックグラウンドでデータをもらう
    // 値を更新する系統はPush
    // チャットは両方使うなどパターンはありそう
    
    // ステータスの変更を伝える
    @Sendable
    func notificationStatus(req: Request) async throws -> HTTPStatus {
        guard let host = req.parameters.get("hostId") else { return .badRequest }
        guard let receiver = req.parameters.get("receiverId") else { return .badRequest }
        guard let status = req.parameters.get("status") else { return .badRequest }
        
//        let hostToken = try await DeviceToken.query(on: req.db).filter(\.$userId == host).first()
        let receiverToken = try await DeviceToken.query(on: req.db).filter(\.$userId == receiver).first()
        let hostUser = try await User.query(on: req.db).filter(\.$userId == host).first()
        
        
        if let receiverToken = receiverToken,
           let hostUser = hostUser {
            let payload = StatusPayload(userId: host, status: status, mode: "status")
            
            let alert = APNSAlertNotification(
                alert: .init(
                    title: .raw("LogiSync"),
                    body: .raw("\(hostUser.name)が\(status)になりました")
                ),
                expiration: .immediately,
                priority: .immediately,
                topic: "com.nanaSoft.LogiSync",
                payload: payload,
                sound: .default
            )
            
            try await req.apns.client.sendAlertNotification(alert, deviceToken: receiverToken.token)
            
            let back = APNSBackgroundNotification(expiration: .immediately, topic:  "com.nanaSoft.LogiSync", payload: payload)
            
            try await req.apns.client.sendBackgroundNotification(back, deviceToken: receiverToken.token)
            
            return .ok
        }
        
        return .badRequest
        
    }
}

struct StatusPayload: Codable {
    var userId: String
    var status: String
    var mode: String
}
