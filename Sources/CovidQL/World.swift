
import Foundation
import GraphZahl
import NIO

class World: Decodable, GraphQLObject {
    let cases: Int
    let deaths: Int
    let recovered: Int
    let active: Int
    let affectedCountries: Int
    let updated: Timestamp

    func timeline(client: Client) throws -> EventLoopFuture<Timeline> {
        return client.timeline()
    }

    func news(client: Client) -> EventLoopFuture<[NewsStory]> {
        return client.stories().map { $0.articles }
    }
}
