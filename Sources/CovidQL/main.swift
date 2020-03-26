
import Foundation
import GraphZahl
import NIO
import Vapor
import GraphZahlVaporSupport
import Runtime

let app = Application(try .detect())
let base = "https://corona.lmao.ninja"

if let port = ProcessInfo.processInfo.environment["PORT"].flatMap(Int.init) {
    app.server.configuration.port = port
} else if case .production = app.environment {
    app.server.configuration.port = 80
    app.server.configuration.hostname = "0.0.0.0"
}

app.routes.graphql(use: CovidQL.self, includeGraphiQL: true) { request in
    return Client(base: base, httpClient: HTTPClient(eventLoopGroupProvider: .shared(request.eventLoop)))
}

try app.run()
