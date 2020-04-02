
import Foundation
import GraphZahl
import NIO

enum CovidQL : GraphQLSchema {
    typealias ViewerContext = Client

    class Query: QueryType {
        let client: Client

        func countries() -> EventLoopFuture<[Country]> {
            return client.countries()
        }

        func world() -> EventLoopFuture<World> {
            return client.all()
        }

        func myCountry() -> EventLoopFuture<Country?> {
            let client = self.client
            return client
                .myCountry()
                .flatMap { country in
                    guard let country = country else { return client.eventLoop.future(nil) }
                    return client.country(name: country)
                }
        }

        func country(name: String) -> EventLoopFuture<Country?> {
            return client.country(name: name)
        }

        func historicalData() -> EventLoopFuture<[HistoricalData]> {
            return client.historicalData()
        }

        required init(viewerContext client: Client) {
            self.client = client
        }
    }
}
