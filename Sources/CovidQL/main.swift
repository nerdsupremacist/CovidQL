
import Foundation
import GraphZahl
import NIO
import Vapor
import GraphZahlVaporSupport
import Runtime

let app = Application(try .detect())
let covidBase = "https://corona.lmao.ninja"
let ipAPIBase = "https://ipapi.co"

app.routes.graphql(use: CovidQL.self, includeGraphiQL: true) { request in
    return Client(ipAddress: request.remoteAddress?.ipAddress,
                  covidBase: covidBase,
                  ipAPIBase: ipAPIBase,
                  httpClient: HTTPClient(eventLoopGroupProvider: .shared(request.eventLoop)))
}

try app.run()
