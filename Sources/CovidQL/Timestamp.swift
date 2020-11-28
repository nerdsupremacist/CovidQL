
import Foundation
import GraphZahl
import GraphQL
import NIO
import ContextKit

@propertyWrapper
struct Timestamp: Decodable, DelegatedOutputResolvable {
    let wrappedValue: Int

    init(from decoder: Decoder) throws {
        wrappedValue = try Int(from: decoder)
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> some OutputResolvable {
        let interval = TimeInterval(wrappedValue / 1000)
        return Date(timeIntervalSince1970: interval)
    }
}
