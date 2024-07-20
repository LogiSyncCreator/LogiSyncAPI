import NIOSSL

import Fluent
import FluentSQLiteDriver
import Vapor
import APNS
import VaporAPNS
import APNSCore
import CryptoKit

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
//    app.http.server.configuration.address = BindAddress.hostname("172.20.10.4", port: 8080)
    
    //  phone =
    //  http://172.20.10.3:8080
    //  home =
    //  http://192.168.68.82:8080
    
    let key = KeyData().apnsKey
    
    app.http.server.configuration.address = BindAddress.hostname(EnvData().ip, port: EnvData().port)
app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    
    let apnsConfig = APNSClientConfiguration(
        authenticationMethod: .jwt(
            privateKey: try .loadFrom(string: key),
            keyIdentifier: KeyData().keiId,
            teamIdentifier: KeyData().teamId),
        environment: .sandbox
    )
    app.apns.containers.use(
        apnsConfig,
        eventLoopGroupProvider: .shared(app.eventLoopGroup),
        responseDecoder: JSONDecoder(),
        requestEncoder: JSONEncoder(),
        as: .default
    )

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateCustomStatus())
    app.migrations.add(CreateNowStatus())
    app.migrations.add(CreateMatching())
    app.migrations.add(CreateChatRoom())
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateThumbnail())
    app.migrations.add(CreateDeviceToken())
    app.migrations.add(CreateChats_2())
    // register routes
    try routes(app)
}
