import Fluent
import APNSCore
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    
    app.get("test-push") { req async throws -> HTTPStatus in
        
        let payload = Payload(title: "test", body: "push", like: "cc")
        
        let alert = APNSAlertNotification(
            alert: .init(
                title: .raw("LogiSync"),
                body: .raw("テスト通知")
            ),
            expiration: .immediately,
            priority: .immediately,
            topic: "com.nanaSoft.LogiSync",
            payload: payload,
            sound: .default
        )
        
        try await req.apns.client.sendAlertNotification(alert, deviceToken: "3b7cc924c3ed8934bc87604a43f5fa99f2c52d9fa0f5cf8416f69febe28ca774")
        
        return .ok
    }
    
    app.get("silent") { req async throws -> HTTPStatus in
        
        let payload = Payload(title: "silent", body: "background", like: "hi")
        
        let alert = APNSBackgroundNotification(expiration: .immediately, topic:  "com.nanaSoft.LogiSync", payload: payload)
        
        try await req.apns.client.sendBackgroundNotification(alert, deviceToken: "3b7cc924c3ed8934bc87604a43f5fa99f2c52d9fa0f5cf8416f69febe28ca774")
        
        return .ok
        
    }

    try app.register(collection: TodoController())
    try app.register(collection: AccountController())
    try app.register(collection: ThumbnailController())
    try app.register(collection: StatusController())
    try app.register(collection: MatchingController())
    try app.register(collection: DeviceTokenController())
    try app.register(collection: LocationController())
}

struct Payload: Codable {
    var title: String
    var body: String
    var like: String
}
