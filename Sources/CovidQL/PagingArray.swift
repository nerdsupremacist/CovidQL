
import Foundation
import GraphZahl
import NIO

struct PagingArray<Node : GraphQLObject>: IndexedConnection {
    static var concreteTypeName: String {
        return "\(Node.concreteTypeName)Connection"
    }

    let values: [Node]

    var identifier: some Hashable {
        return values.count
    }

    // This is our way to respect better performance
    func defaultPageSize(eventLoop: EventLoopGroup) -> EventLoopFuture<Int?> {
        return eventLoop.future(20)
    }

    func totalCount(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return eventLoop.future(values.count)
    }

    func nodes(offset: Int, size: Int, eventLoop: EventLoopGroup) -> EventLoopFuture<[Node?]?> {
        return eventLoop.future(values[offset..<offset+size].map(Optional.some))
    }
}

extension PagingArray: Decodable where Node : Decodable {

    init(from decoder: Decoder) throws {
        self.init(values: try .init(from: decoder))
    }

}
