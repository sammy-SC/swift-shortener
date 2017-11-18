import Vapor

final class LinkController {

    let viewRenderer: ViewRenderer

    init(viewRenderer: ViewRenderer) {
        self.viewRenderer = viewRenderer
    }

    func addRoutes(to drop: Droplet) {
        drop.get(handler: indexHandler)
        drop.get("/", Int.parameter, handler: redirect)
        drop.post("/", handler: store)
    }

    private func indexHandler(_ req: Request) throws -> ResponseRepresentable {
        return try viewRenderer.make("index")
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let link = try req.link()
        try link.save()

        guard let id = link.id?.string else {
            throw Abort.serverError
        }
        let url = "localhost:8080/\(id)"
        if req.json != nil {
            return JSON(.object(["link": .string(url)]))
        } else {
            return try viewRenderer.make("index", [
                "link": url
                ])
        }
    }

    func redirect(_ req: Request) throws -> ResponseRepresentable {
        let linkId = try req.parameters.next(Int.self)
        guard let link = try Link.find(linkId) else {
            throw Abort.notFound
        }
        return Response(redirect: link.link, .permanent)
    }
}

extension Request {
    fileprivate func link() throws -> Link {
        if let json = json {
            return try Link(node: json)
        } else if let form = formURLEncoded {
            return try Link(node: form)
        } else {
            throw Abort.badRequest
        }
    }
}

