
import Foundation
import GraphZahl
import NIO

enum CovidQL : GraphQLSchema {
    typealias ViewerContext = Client

    class Query: QueryType {
        let client: Client

        func countries() -> EventLoopFuture<[Country]> {
            return client.countries().map { $0.filter { $0.info.latitude != 0 || $0.info.longitude != 0 } }
        }

        func world() -> EventLoopFuture<World> {
            return client.all()
        }

        func myCountry() -> EventLoopFuture<Country?> {
            let client = self.client
            return client
                .locateUser()
                .flatMap { location in
                    guard let location = location else { return client.eventLoop.future(nil) }
                    return client.country(name: location.countryCode)
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
