import Fluent
import Vapor

struct TodoController: RouteCollection {
    /// コントローラーのブート
    func boot(routes: RoutesBuilder) throws {
        /// todosグループの作成
        /// http://localhost:8080/groups
        let todos = routes.grouped("todos")

        /// エンドポイント
        /// - group.method("endpoint", use: function)
        /// - グループ内の任意メソッドでアクセスされた時にfunctionを実行
        todos.get(use: self.index)
        todos.post(use: self.create)
        todos.group(":todoID") { todo in
            todo.delete(use: self.delete)
        }
    }

    @Sendable
    /// アクセスされた時に実行する
    /// - Parameter req: リクエストの内容
    /// - Returns: TodoDTO配列を返す
    ///     - DTOクラス（Content）はパラメータやjsonなどをVaporで扱うためのクラス
    ///     - Modelクラス Fluentで使用するSQLオブジェクト
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
    }

    
    /// アクセスされた時に実行する
    /// - Parameter req: リクエストの内容
    /// - Returns: TodoDTOを返す
    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        /// リクエストのjsonをTodoDTOにデコードしてモデル化することでSQLで使用できるようにする
        let todo = try req.content.decode(TodoDTO.self).toModel()

        /// データベースに保存
        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    /// HTTPステータスを返すものについて
    ///  - .notFoundのQuick Helpより4XX系のステータスであることがわかる
    ///  →404
    ///  - .noContent
    ///  →201
    ///  - .ok
    ///  →200
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
}
