
import Foundation
import GraphZahl
import NIO
import Vapor
import GraphZahlVaporSupport
import Runtime

let app = Application(try .detect())
let covidBase = "https://corona.lmao.ninja"
let ipAPIBase = "https://api.ipgeolocation.io/"
let newsBase = "https://newsapi.org/v2/"

app.routes.graphql(use: CovidQL.self, includeGraphiQL: true) { request in
    return Client(ipAddress: request.remoteAddress?.ipAddress,
                  covidBase: covidBase,
                  ipAPIBase: ipAPIBase,
                  ipAPIKey: "eee9c9c23de44033a19b44be776e3a42",
                  newsBase: newsBase,
                  newsAPIKey: "8189f8976f2846ee8985371ff84d580a",
                  httpClient: HTTPClient(eventLoopGroupProvider: .shared(request.eventLoop)))
}

try app.run()
