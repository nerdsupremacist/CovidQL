
import Foundation
import GraphZahl
import NIO

class World: Decodable, GraphQLObject {
    let cases: Int
    let deaths: Int
    let recovered: Int

    func timeline(client: Client) throws -> EventLoopFuture<Timeline> {
        return client.timeline()
    }
}
