import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateCustomStatus())
    app.migrations.add(CreateNowStatus())
    app.migrations.add(CreateMatching())
    app.migrations.add(CreateChatRoom())
    app.migrations.add(CreateChat())
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateThumbnail())
    app.migrations.add(CreateDeviceToken())
    // register routes
    try routes(app)
}
