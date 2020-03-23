
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

        func current() -> EventLoopFuture<CurrentState> {
            return client.all()
        }

        func country(name: String) -> EventLoopFuture<Country> {
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
