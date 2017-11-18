import Vapor
import FluentProvider
import HTTP

final class Link: Model {
    let storage = Storage()

    // MARK: Properties and database keys

    var link: String

    struct Keys {
        static let id = "id"
        static let link = "link"
    }

    init(link: String) {
        self.link = link
    }

    // MARK: Fluent Serialization

    init(row: Row) throws {
        link = try row.get(Link.Keys.link)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Link.Keys.link, link)
        return row
    }
}

// MARK: Fluent Preparation

extension Link: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Link.Keys.link)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Link: NodeInitializable {
    convenience init(node: Node) throws {
        self.init(link: try node.get(Link.Keys.link))
    }
}
