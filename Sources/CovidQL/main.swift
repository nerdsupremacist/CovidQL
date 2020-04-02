
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

app.routes.graphql(use: CovidQL.self, includeGraphiQL: true) { (request: Request) -> Client in
    let ipAddress = request.headers.forwarded.first?.for ?? request.remoteAddress?.ipAddress
    return Client(ipAddress: ipAddress,
                  covidBase: covidBase,
                  ipAPIBase: ipAPIBase,
                  ipAPIKey: "eee9c9c23de44033a19b44be776e3a42",
                  newsBase: newsBase,
                  newsAPIKey: "8189f8976f2846ee8985371ff84d580a",
                  httpClient: HTTPClient(eventLoopGroupProvider: .shared(request.eventLoop)))
}

try app.run()
