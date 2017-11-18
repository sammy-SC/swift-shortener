import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class RouteTests: TestCase {
    var drop: Droplet!
    override func setUp() {
        super.setUp()
        drop = try! Droplet.testable()
    }

    func testHomepage() throws {
        try drop.testResponse(to: .get, at: "/")
            .assertStatus(is: .ok)
            .assertBody(contains: "<input type=\"text\" name=\"link\">")
    }

    func testCreationFromForm() throws {
        let node = try Node(["link": "www.google.com"]).formURLEncoded()

        let body: Body = .data(node)

        let request = Request(method: .post,
                              uri: "/",
                              headers: [HeaderKey.contentType: "application/x-www-form-urlencoded"],
                              body: body)
        try drop
            .testResponse(to: request)
            .assertStatus(is: .ok)
            .assertBody(contains: "localhost:8080/1")
    }

    func testCreationFromJSON() throws {
        let requestBody = try Body(["link": "www.google.com"])
        let request = Request(method: .post,
                              uri: "/",
                              headers: [HeaderKey.contentType: "application/json"],
                              body: requestBody)

        try drop
            .testResponse(to: request)
            .assertStatus(is: .ok)
            .assertJSON("link", equals: "localhost:8080/1")
    }

    func testRedirect() throws {
        let link = try Link(node: ["link": "www.google.com"])
        try link.save()
        try drop
            .testResponse(to: .get, at: "/1")
            .assertStatus(is: .movedPermanently)
            .assertHeader("Location", contains: "www.google.com")
    }
}

// MARK: Manifest

extension RouteTests {
    static let allTests = [
        ("testHomepage", testHomepage),
        ("testCreationFromForm", testCreationFromForm),
        ("testCreationFromJSON", testCreationFromJSON),
        ("testRedirect", testRedirect)
    ]
}

