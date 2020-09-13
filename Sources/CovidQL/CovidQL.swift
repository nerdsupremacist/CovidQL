
import Foundation
import GraphZahl
import NIO

enum CovidQL : GraphQLSchema {
    typealias ViewerContext = Client

    class Query: QueryType {
        let client: Client

        func countries() -> EventLoopFuture<PagingArray<Country>> {
            return client
                .countries()
                .map { $0.filter { $0.info.latitude != 0 || $0.info.longitude != 0 }.sorted { $0.cases > $1.cases } }
                .map { PagingArray(values: $0) }
        }

        func continents() -> EventLoopFuture<[Continent]> {
            return client.continents().map { $0.sorted { $0.cases > $1.cases } }
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
                    return client.country(identifier: Identifier(rawValue: location.countryCode)).map(Optional.some)
                }
        }

        func country(identifier: Identifier<Country>) -> EventLoopFuture<Country> {
            return client.country(identifier: identifier)
        }

        func continent(identifier: Identifier<Continent>) -> EventLoopFuture<DetailedContinent> {
            return client.continent(identifier: identifier)
        }

        func historicalData() -> EventLoopFuture<PagingArray<HistoricalData>> {
            return client.historicalData().map { PagingArray(values: $0) }
        }

        required init(viewerContext client: Client) {
            self.client = client
        }
    }
}
