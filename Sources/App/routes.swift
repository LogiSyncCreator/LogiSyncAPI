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

    try app.register(collection: TodoController())
    try app.register(collection: AccountController())
    try app.register(collection: ThumbnailController())
    try app.register(collection: StatusController())
    try app.register(collection: MatchingController())
    try app.register(collection: DeviceTokenController())
    try app.register(collection: LocationController())
    try app.register(collection: PushController())
}

struct Payload: Codable {
    var title: String
    var body: String
    var like: String
}
