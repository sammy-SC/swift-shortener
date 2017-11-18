import Vapor

extension Droplet {
    func setupRoutes() throws {
        let linkController = LinkController(viewRenderer: view)
        linkController.addRoutes(to: self)
    }
}
