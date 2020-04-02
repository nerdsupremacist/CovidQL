
import Foundation
import GraphZahl
import GraphQL
import NIO
import ContextKit

@propertyWrapper
struct Timestamp: Decodable, OutputResolvable {
    static let additionalArguments: [String : InputResolvable.Type] = [:]

    static func reference(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.reference(for: Date.self)
    }

    static func resolve(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.resolve(type: Date.self)
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> EventLoopFuture<Any?> {
        let interval = TimeInterval(wrappedValue / 1000)
        let date = Date(timeIntervalSince1970: interval)
        return date.resolve(source: source, arguments: arguments, context: context, eventLoop: eventLoop)
    }

    let wrappedValue: Int

    init(from decoder: Decoder) throws {
        wrappedValue = try Int(from: decoder)
    }
}
