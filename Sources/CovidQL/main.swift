
import Foundation
import GraphZahl
import NIO
import Vapor
import GraphZahlVaporSupport
import Runtime
import Cache

let clientEventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 10)
let cacheConfig = MemoryConfig(expiry: .never, countLimit: 500, totalCostLimit: 100_000)
let cache = MemoryStorage<String, Any>(config: cacheConfig)

let app = Application(try .detect())
let covidBase = "https://corona.lmao.ninja"
let ipAPIBase = "https://api.ipgeolocation.io/"
let newsBase = "https://newsapi.org/v2/"

extension Client {

    static func client(for request: Request? = nil) -> Client {
        let ipAddress = request?.headers.forwarded.first?.for ?? request?.remoteAddress?.ipAddress
        return Client(ipAddress: ipAddress,
                      covidBase: covidBase,
                      ipAPIBase: ipAPIBase,
                      ipAPIKey: "eee9c9c23de44033a19b44be776e3a42",
                      newsBase: newsBase,
                      newsAPIKey: "8189f8976f2846ee8985371ff84d580a",
                      featuresUrl: "https://raw.githubusercontent.com/johan/world.geo.json/master/countries.geo.json",
                      cache: cache,
                      httpClient: HTTPClient(eventLoopGroupProvider: .shared(clientEventLoop)))
    }

}


try CovidQL.prepare(viewerContext: Client.client())

app.routes.graphql(use: CovidQL.self, includeGraphiQL: true) { (request: Request) -> Client in
    Client.client(for: request)
}

try app.run()
